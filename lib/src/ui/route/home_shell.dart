import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';

import '../../backend/app_version/domain/github.dart';
import '../../backend/fs_interface/data/helper/path_op_string.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/app_state.dart';
import '../../di/app_version.dart';
import '../../di/exe_arg.dart';
import '../../di/fs_interface.dart';
import '../../di/fs_watcher.dart';
import '../route_names.dart';
import '../util/display_infobar.dart';
import '../util/open_url.dart';
import '../widget/appbar.dart';
import '../widget/category_drop_target.dart';
import '../widget/custom_image.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';

Future<void> _runUpdateScript() async {
  final url = Uri.parse('$kRepoReleases/download/GenshinModManager.zip');
  final response = await http.get(url);
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  await extractArchiveToDiskAsync(
    archive,
    Directory.current.path,
    asyncWrite: true,
  );
  const updateScript = 'setlocal\n'
      'echo update script running\n'
      'set "sourceFolder=GenshinModManager"\n'
      'if not exist "genshin_mod_manager.exe" (\n'
      '    echo Maybe not in the mod manager folder? Exiting for safety.\n'
      '    pause\n'
      '    exit /b 1\n'
      ')\n'
      'if not exist %sourceFolder% (\n'
      '    echo Failed to download data! Go to the link and install manually.\n'
      '    pause\n'
      '    exit /b 2\n'
      ')\n'
      "echo So it's good to go. Let's update.\n"
      "for /f \"delims=\" %%i in ('dir /b /a-d ^| findstr /v /i \"update.cmd update.log error.log\"') do del \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b /ad ^| findstr /v /i \"Resources %sourceFolder%\"') do rd /s /q \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b \"%sourceFolder%\"') do move /y \"%sourceFolder%\\%%i\" .\n"
      'rd /s /q %sourceFolder%\n'
      'start /b genshin_mod_manager.exe\n'
      'endlocal\n';
  await File('update.cmd').writeAsString(updateScript);
  unawaited(
    Process.run(
      'start',
      [
        'cmd',
        '/c',
        'timeout /t 3 && call update.cmd > update.log & del update.cmd',
      ],
      runInShell: true,
    ),
  );
  // delay needed. otherwise the process will die before the script runs.
  await Future<void>.delayed(const Duration(milliseconds: 200));
  exit(0);
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _FolderPaneItem extends PaneItem {
  _FolderPaneItem({
    required this.category,
    required super.key,
    super.onTap,
  }) : super(
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _getIcon(category.name),
          body: const SizedBox.shrink(),
        );
  static const maxIconWidth = 80.0;
  ModCategory category;

  @override
  Widget build(
    final BuildContext context,
    final bool selected,
    final VoidCallback? onPressed, {
    final PaneDisplayMode? displayMode,
    final bool showTextOnTop = true,
    final int? itemIndex,
    final bool? autofocus,
  }) =>
      CategoryDropTarget(
        category: category,
        child: super.build(
          context,
          selected,
          onPressed,
          displayMode: displayMode,
          showTextOnTop: showTextOnTop,
          itemIndex: itemIndex,
          autofocus: autofocus,
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

  static Widget _buildImage(final String? imageFile) {
    final Widget image;
    if (imageFile == null) {
      image = Consumer(
        builder: (final context, final ref, final child) {
          final usePaimon = ref.watch(paimonIconProvider);
          return usePaimon
              ? Image.asset('images/app_icon.ico')
              : Image.asset('images/idk_icon.png');
        },
      );
    } else {
      image = TimeAwareFileImage(path: imageFile);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxIconWidth),
      child: AspectRatio(
        aspectRatio: 1,
        child: image,
      ),
    );
  }

  static Widget _getIcon(final String name) => Consumer(
        builder: (final context, final ref, final child) {
          final filePath = ref.watch(folderIconPathProvider(name));
          return ref.watch(folderIconProvider)
              ? _buildImage(filePath)
              : const Icon(FluentIcons.folder_open);
        },
      );
}

class _HomeShellState<T extends StatefulWidget> extends ConsumerState<HomeShell>
    with WindowListener {
  static const _navigationPaneOpenWidth = 270.0;

  @override
  Widget build(final BuildContext context) {
    ref.listen(isOutdatedProvider, (final previous, final next) async {
      if (next is AsyncData && next.requireValue) {
        final remote = await ref.read(remoteVersionProvider.future);
        _displayUpdateInfoBar(remote!);
      }
    });

    if (ref.watch(gamesListProvider).isEmpty) {
      return NavigationView(
        appBar: getAppbar('Set the first game name'),
        content: ScaffoldPage.withPadding(
          header: const PageHeader(
            title: Text('Set the first game name'),
          ),
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('My game is...'),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: TextFormBox(
                    placeholder: 'Game name',
                    onFieldSubmitted: (final value) {
                      ref.read(gamesListProvider.notifier).addGame(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final categories = ref.watch(categoriesProvider);
    return _buildData(categories);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);

    final args = ref.read(argProviderProvider);
    if (args.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback(
        (final timeStamp) {
          final arg = args.first;
          if (arg == AcceptedArg.run3dm.cmd) {
            unawaited(_runMigoto());
          } else if (arg == AcceptedArg.rungame.cmd) {
            unawaited(_runLauncher());
          } else if (arg == AcceptedArg.runboth.cmd) {
            unawaited(_runBoth());
          } else {
            unawaited(
              showDialog(
                context: context,
                builder: (final dCtx) {
                  final validArgs =
                      AcceptedArg.values.map((final e) => e.cmd).join(', ');
                  return ContentDialog(
                    title: const Text('Invalid argument'),
                    content: Text('Unknown argument: $arg.\n'
                        'Valid args are: $validArgs'),
                    actions: [
                      FilledButton(
                        onPressed: Navigator.of(dCtx).pop,
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              ),
            );
          }
          ref.read(argProviderProvider.notifier).clear();
        },
      );
    }

    final read = ref.read(windowSizeProvider);
    if (read != null) {
      unawaited(WindowManager.instance.setSize(read));
    }
  }

  @override
  void onWindowFocus() {
    ref.invalidate(categoriesProvider);
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    unawaited(
      WindowManager.instance
          .getSize()
          .then(ref.read(windowSizeProvider.notifier).setValue),
    );
  }

  Widget _buildAutoSuggestBox(
    final List<_FolderPaneItem> items,
    final List<NavigationPaneItem> footerItems,
  ) =>
      AutoSuggestBox2(
        items: items
            .map(
              (final e) => AutoSuggestBoxItem2(
                value: e.key,
                label: e.category.name,
                onSelected: () =>
                    context.go(RouteNames.category.name, extra: e.category),
              ),
            )
            .toList(),
        trailingIcon: const Icon(FluentIcons.search),
        onSubmissionFailed: (final text) {
          if (text.isEmpty) {
            return;
          }
          final index = items.indexWhere((final e) {
            final name =
                (e.key! as ValueKey<ModCategory>).value.name.toLowerCase();
            return name.startsWith(text.toLowerCase());
          });
          if (index == -1) {
            return;
          }
          final category = items[index].category;
          context.go(RouteNames.category.name, extra: category);
        },
      );

  NavigationView _buildData(final List<ModCategory> categories) {
    final game = ref.watch(targetGameProvider);
    final updateMarker = ref.watch(isOutdatedProvider).maybeWhen(
          data: (final value) => value ? ' (update!)' : '',
          orElse: () => '',
        );
    return NavigationView(
      appBar: getAppbar(
        '$game Mod Manager$updateMarker',
        presetControl: true,
      ),
      pane: _buildPane(categories),
      paneBodyBuilder: (final item, final body) => widget.child,
    );
  }

  NavigationPane _buildPane(final List<ModCategory> categories) {
    final items = categories
        .map(
          (final e) => _FolderPaneItem(
            category: e,
            key: Key('${RouteNames.category.name}/${e.name}'),
            onTap: () => context.go('${RouteNames.category.name}/${e.name}'),
          ),
        )
        .toList();
    final footerItems = [
      PaneItemSeparator(),
      ..._buildPaneItemActions(),
      PaneItem(
        key: Key(RouteNames.setting.name),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () => context.go(RouteNames.setting.name),
      ),
    ];

    final effectiveItems = ((items.cast<NavigationPaneItem>() + footerItems)
          ..removeWhere((final i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();

    final currentRoute = GoRouterState.of(context).uri.toString();
    final index = effectiveItems.indexWhere((final e) {
      final key = e.key;
      return key is ValueKey<String> && currentRoute == key.value;
    });

    return NavigationPane(
      selected: index != -1 ? index : null,
      items: items.cast<NavigationPaneItem>(),
      footerItems: footerItems,
      size: const NavigationPaneSize(
        openWidth: _HomeShellState._navigationPaneOpenWidth,
      ),
      autoSuggestBox: _buildAutoSuggestBox(items, footerItems),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
    );
  }

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    final select = ref.watch(runTogetherProvider);
    final override = ref.watch(separateRunOverrideProvider);
    return override ?? select
        ? [
            PaneItemAction(
              key: const Key('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: _runBoth,
            ),
          ]
        : [
            PaneItemAction(
              key: const Key('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: _runMigoto,
            ),
            PaneItemAction(
              key: const Key('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: _runLauncher,
            ),
          ];
  }

  void _displayUpdateInfoBar(final String newVersion) {
    unawaited(
      displayInfoBarInContext(
        context,
        duration: const Duration(minutes: 1),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(text: 'New version available: '),
              TextSpan(
                text: newVersion,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '. Click '),
              TextSpan(
                text: 'here',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => openUrl(kRepoReleases),
              ),
              const TextSpan(text: ' to open link.'),
            ],
          ),
        ),
        action: FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (final dialogContext) {
              final reason = _findUpdateUnableReason();
              final Widget filledButton;
              if (reason.isNotEmpty) {
                filledButton = MouseRegion(
                  cursor: SystemMouseCursors.forbidden,
                  child: Tooltip(
                    message: 'The auto-update will delete one or more of the'
                        " following: ${reason.join(', ')}!",
                    child: const FilledButton(
                      onPressed: null,
                      child: Text('Start'),
                    ),
                  ),
                );
              } else {
                filledButton = FilledButton(
                  child: const Text('Start'),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _runUpdateScript();
                  },
                );
              }

              return ContentDialog(
                title: const Text('Start auto update?'),
                content: _getAutoUpdateWarning(),
                actions: [
                  Button(
                    onPressed: Navigator.of(dialogContext).pop,
                    child: const Text('Cancel'),
                  ),
                  FluentTheme(
                    data: FluentThemeData(accentColor: Colors.red),
                    child: filledButton,
                  ),
                ],
              );
            },
          ),
          child: const Text('Auto update'),
        ),
      ),
    );
  }

  List<String> _findUpdateUnableReason() {
    final appState = ref.read(gameConfigNotifierProvider);
    final modRoot = appState.modRoot;
    final migotoRoot = appState.modExecFile;
    final launcherRoot = appState.launcherFile;
    final execRoot = File(Platform.resolvedExecutable).parent.path;

    final reason = <String>[];
    if (modRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('mods');
    }
    if (migotoRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('3d migoto');
    }
    if (launcherRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('launcher');
    }
    return reason;
  }

  RichText _getAutoUpdateWarning() => RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            const TextSpan(
              text: 'This will download the latest version'
                  ' and replace the current one.'
                  ' This feature is experimental'
                  ' and may not work as expected.\n',
              // justify
            ),
            TextSpan(
              text: 'Please backup your mods'
                  ' and resources before proceeding.\n'
                  'DELETION OF UNRELATED FILES IS POSSIBLE.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Future<void> _runBoth() async {
    await _runMigoto();
    await _runLauncher();
  }

  Future<void> _runLauncher() async {
    final launcher = ref.read(gameConfigNotifierProvider).launcherFile;
    final fsInterface = ref.read(fsInterfaceProvider);
    if (launcher == null) {
      return;
    }
    await fsInterface.runProgram(File(launcher));
  }

  Future<void> _runMigoto() async {
    final path = ref.read(gameConfigNotifierProvider).modExecFile;
    final fsInterface = ref.read(fsInterfaceProvider);
    if (path == null) {
      return;
    }
    await fsInterface.runProgram(File(path));
    if (!mounted) {
      return;
    }
    await displayInfoBarInContext(
      context,
      title: const Text('Ran 3d migoto'),
    );
  }
}
