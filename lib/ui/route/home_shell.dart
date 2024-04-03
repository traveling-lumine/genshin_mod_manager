import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/flow/app_version.dart';
import 'package:genshin_mod_manager/flow/home_shell.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/util/open_url.dart';
import 'package:genshin_mod_manager/ui/widget/appbar.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:window_manager/window_manager.dart';

const _kRepoReleases = '$kRepoBase/releases/latest';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.child});

  final Widget child;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState<T extends StatefulWidget> extends ConsumerState<HomeShell>
    with WindowListener {
  static const _navigationPaneOpenWidth = 270.0;

  @override
  void onWindowFocus() {
    ref.read(homeShellListProvider.notifier).refresh();
  }

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    ref.listen(isOutdatedProvider, (final previous, final next) async {
      if (next is AsyncData && next.requireValue) {
        final remote = await ref.read(remoteVersionProvider.future);
        _displayUpdateInfoBar(remote!);
      }
    });
    final categories = ref.watch(homeShellListProvider);
    return categories.when(
      data: _buildData,
      error: _buildError,
      loading: _buildLoading,
    );
  }

  NavigationView _buildData(final List<ModCategory> categories) {
    final footerItems = [
      PaneItemSeparator(),
      ..._buildPaneItemActions(),
      PaneItem(
        key: const Key(kSettingRoute),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () => context.go(kSettingRoute),
      ),
    ];
    final items = categories.map((final e) {
      final iconPath = e.iconPath;
      return _FolderPaneItem(
        category: e,
        imageFile: iconPath != null ? File(iconPath) : null,
        onTap: () => context.go(kCategoryRoute, extra: e),
      );
    }).toList();

    final effectiveItems = ((items.cast<NavigationPaneItem>() + footerItems)
          ..removeWhere((final i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();

    final currentRouteExtra = GoRouterState.of(context).extra;
    final index = effectiveItems.indexWhere((final e) {
      final key = e.key;
      if (key is! ValueKey<ModCategory>) {
        return false;
      }
      return key.value == currentRouteExtra;
    });

    final selected = index != -1 ? index : null;

    final uri = GoRouterState.of(context).uri;
    final uriSegments = uri.pathSegments;
    if (uriSegments.length == 1 &&
        uriSegments[0] == 'category' &&
        !categories.any((final e) => e == currentRouteExtra)) {
      final String destination;
      final ModCategory? extra;
      if (categories.isNotEmpty) {
        final index = _search(categories, currentRouteExtra! as ModCategory);
        destination = kCategoryRoute;
        extra = categories[index];
      } else {
        destination = kHomeRoute;
        extra = null;
      }
      SchedulerBinding.instance.addPostFrameCallback((final timeStamp) {
        context.go(destination, extra: extra);
      });
    }

    return NavigationView(
      appBar: getAppbar(
        'Genshin Mod Manager${ref.watch(isOutdatedProvider).maybeWhen(
              data: (final value) => value ? ' (update!)' : '',
              orElse: () => '',
            )}',
        presetControl: true,
      ),
      pane: _buildPane(selected, items, footerItems),
      paneBodyBuilder: (final item, final body) => widget.child,
    );
  }

  NavigationView _buildError(final Object error, final StackTrace stackTrace) =>
      NavigationView(
        appBar: getAppbar('Error'),
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              Text('Stack trace: $stackTrace'),
            ],
          ),
        ),
      );

  NavigationView _buildLoading() => NavigationView(
        appBar: getAppbar("Reading categories..."),
        content: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(),
              Text('Reading categories...'),
            ],
          ),
        ),
      );

  NavigationPane _buildPane(
    final int? selected,
    final List<_FolderPaneItem> items,
    final List<NavigationPaneItem> footerItems,
  ) =>
      NavigationPane(
        selected: selected,
        items: items.cast<NavigationPaneItem>(),
        footerItems: footerItems,
        size: const NavigationPaneSize(
          openWidth: _HomeShellState._navigationPaneOpenWidth,
        ),
        autoSuggestBox: _buildAutoSuggestBox(items, footerItems),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
      );

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    final select = ref.watch(
      appStateNotifierProvider.select((final value) => value.runTogether),
    );
    return select
        ? [
            PaneItemAction(
              key: const ValueKey('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: _runBoth,
            ),
          ]
        : [
            PaneItemAction(
              key: const ValueKey('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: _runMigoto,
            ),
            PaneItemAction(
              key: const ValueKey('<run_launcher>'),
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
                  ..onTap = () => openUrl(_kRepoReleases),
              ),
              const TextSpan(text: ' to open link.'),
            ],
          ),
        ),
        action: FilledButton(
          onPressed: () => showDialog(
            context: context,
            builder: (final dialogContext) => ContentDialog(
              title: const Text('Start auto update?'),
              content: _getAutoUpdateWarning(),
              actions: [
                Button(
                  onPressed: Navigator.of(dialogContext).pop,
                  child: const Text('Cancel'),
                ),
                FluentTheme(
                  data: FluentThemeData(accentColor: Colors.red),
                  child: FilledButton(
                    child: const Text('Start'),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _runUpdateScript();
                    },
                  ),
                ),
              ],
            ),
          ),
          child: const Text('Auto update'),
        ),
      ),
    );
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

  void _runBoth() {
    _runMigoto();
    _runLauncher();
  }

  void _runMigoto() {
    final path = ref.read(appStateNotifierProvider).modExecFile;
    if (path == null) {
      return;
    }
    runProgram(File(path));
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Ran 3d migoto'),
      ),
    );
  }

  void _runLauncher() {
    final launcher = ref.read(appStateNotifierProvider).launcherFile;
    if (launcher == null) {
      return;
    }
    runProgram(File(launcher));
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
                onSelected: () => context.go(kCategoryRoute, extra: e.category),
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
          context.go(kCategoryRoute, extra: category);
        },
      );
}

class _FolderPaneItem extends PaneItem {
  _FolderPaneItem({
    required this.category,
    super.onTap,
    final File? imageFile,
  }) : super(
          key: ValueKey(category),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _getIcon(imageFile),
          body: const SizedBox.shrink(),
        );
  static const maxIconWidth = 80.0;

  static Widget _getIcon(final File? imageFile) => Consumer(
        builder: (final context, final ref, final child) {
          final value = ref.watch(
            appStateNotifierProvider
                .select((final value) => value.showFolderIcon),
          );
          return value
              ? _buildImage(imageFile)
              : const Icon(FluentIcons.folder_open);
        },
      );

  static Widget _buildImage(final File? imageFile) {
    final Image image;
    if (imageFile == null) {
      image = Image.asset('images/app_icon.ico');
    } else {
      image = Image.file(
        imageFile,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxIconWidth),
      child: AspectRatio(
        aspectRatio: 1,
        child: image,
      ),
    );
  }

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
}

Future<void> _runUpdateScript() async {
  final url = Uri.parse('$_kRepoReleases/download/GenshinModManager.zip');
  final response = await http.get(url);
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  await extractArchiveToDiskAsync(
    archive,
    Directory.current.path,
    asyncWrite: true,
  );
  const updateScript = "setlocal\n"
      "echo update script running\n"
      'set "sourceFolder=GenshinModManager"\n'
      'if not exist "genshin_mod_manager.exe" (\n'
      "    echo Maybe not in the mod manager folder? Exiting for safety.\n"
      "    pause\n"
      "    start cmd /c del update.cmd\n"
      "    exit /b 1\n"
      ")\n"
      "if not exist %sourceFolder% (\n"
      "    echo Failed to download data! Go to the link and install manually.\n"
      "    pause\n"
      "    start cmd /c del update.cmd\n"
      "    exit /b 2\n"
      ")\n"
      "echo So it's good to go. Let's update.\n"
      "for /f \"delims=\" %%i in ('dir /b /a-d ^| findstr /v /i \"update.cmd update.log error.log\"') do del \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b /ad ^| findstr /v /i \"Resources %sourceFolder%\"') do rd /s /q \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b \"%sourceFolder%\"') do move /y \"%sourceFolder%\\%%i\" .\n"
      "rd /s /q %sourceFolder%\n"
      "start /b genshin_mod_manager.exe\n"
      "start cmd /c del update.cmd\n"
      "endlocal\n";
  await File('update.cmd').writeAsString(updateScript);
  unawaited(
    Process.run(
      'start',
      [
        'cmd',
        '/c',
        'timeout /t 3 && call update.cmd > update.log',
      ],
      runInShell: true,
    ),
  );
  await Future.delayed(const Duration(milliseconds: 200));
  exit(0);
}

int _search(final List<ModCategory> categories, final ModCategory category) {
  final length = categories.length;
  var lo = 0;
  var hi = length;
  while (lo < hi) {
    final mid = lo + ((hi - lo) >> 1);
    if (compareNatural(categories[mid].name, category.name) < 0) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  if (lo >= length) {
    return length - 1;
  }
  return lo;
}
