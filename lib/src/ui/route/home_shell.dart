import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

import '../../backend/nahida/domain/entity/download_state.dart';
import '../../backend/nahida/domain/entity/nahida_element.dart';
import '../../backend/app_version/domain/github.dart';
import '../../backend/fs_interface/domain/helper/path_op_string.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/nahida_download_queue.dart';
import '../../di/app_state/current_target_game.dart';
import '../../di/app_state/game_config.dart';
import '../../di/app_state/games_list.dart';
import '../../di/app_state/run_together.dart';
import '../../di/app_state/separate_run_override.dart';
import '../../di/app_state/window_size.dart';
import '../../di/app_version/is_outdated.dart';
import '../../di/app_version/remote_version.dart';
import '../../di/exe_arg.dart';
import '../../di/nahida_store.dart';
import '../../di/structure/categories.dart';
import '../constants.dart';
import '../util/display_infobar.dart';
import '../util/open_url.dart';
import '../widget/appbar.dart';
import '../widget/category_pane_item.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';

Future<Never> _runUpdateScript() async {
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
  await Process.start(
    'start',
    [
      'cmd',
      '/c',
      'timeout /t 3 && call update.cmd > update.log & del update.cmd',
    ],
    runInShell: true,
  );
  exit(0);
}

class HomeShell extends StatefulHookConsumerWidget {
  const HomeShell({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class RunAndExitPaneAction extends PaneItemAction {
  RunAndExitPaneAction({
    required super.icon,
    required Widget super.title,
    required Future<void> Function() super.onTap,
    required final FlyoutController flyoutController,
    super.key,
  }) : super(
          trailing: FlyoutTarget(
            controller: flyoutController,
            child: IconButton(
              icon: const Icon(FluentIcons.more),
              onPressed: () => _showRunAndExitFlyout(flyoutController, onTap),
            ),
          ),
        );

  static Future<void> _showRunAndExitFlyout(
    final FlyoutController flyoutController,
    final Future<void> Function() onTap,
  ) async =>
      flyoutController.showFlyout(
        builder: (final context) => FlyoutContent(
          child: IntrinsicWidth(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.clip,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.power_button),
                  label: const Text('Run and exit'),
                  onPressed: () async {
                    await onTap();
                    exit(0);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

class _HomeShellState<T extends StatefulWidget> extends ConsumerState<HomeShell>
    with WindowListener, ProtocolListener {
  static const _navigationPaneOpenWidth = 270.0;
  final _textEditingController = TextEditingController();
  final _flyoutController = FlyoutController();

  @override
  Widget build(final BuildContext context) {
    ref
      ..listen(isOutdatedProvider, (final previous, final next) async {
        if (next is AsyncData && next.requireValue) {
          final remote = await ref.read(remoteVersionProvider.future);
          unawaited(_showUpdateInfoBar(remote!));
        }
      })
      ..listen(
        gamesListProvider,
        (final previous, final next) {
          if (next.isEmpty) {
            context.go(RouteNames.firstpage.name);
          }
        },
      )
      ..listen(
        nahidaDownloadQueueProvider,
        (final previous, final next) async {
          if (!next.hasValue) {
            return;
          }
          switch (next.requireValue) {
            case NahidaDownloadStateCompleted(:final element):
              _showNahidaDownloadCompleteInfoBar(element);
            case NahidaDownloadStateHttpException(:final exception):
              _showNahidaApiErrorInfoBar(exception);
            case NahidaDownloadStateWrongPassword(
                :final completer,
                :final wrongPw
              ):
              await _showNahidaWrongPasswdDialog(completer, wrongPw);
            case NahidaDownloadStateModZipExtractionException(
                :final category,
                :final data,
                :final element
              ):
              await _showNahidaZipExtractionErrorInfoBar(
                element,
                category,
                data,
              );
          }
        },
      );

    final game = ref.watch(targetGameProvider);
    final updateMarker = (ref.watch(isOutdatedProvider).valueOrNull ?? false)
        ? AppLocalizations.of(context)!.updateMarker
        : '';
    return NavigationView(
      appBar: getAppbar(
        AppLocalizations.of(context)!.modManager(game, updateMarker),
        presetControl: true,
      ),
      pane: _buildPane(),
      paneBodyBuilder: (final item, final body) => widget.child,
    );
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    protocolHandler.removeListener(this);
    _flyoutController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
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
            unawaited(_showInvalidCommandDialog(arg));
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
  void onProtocolUrlReceived(final String url) {
    if (mounted) {
      unawaited(
        showDialog(
          context: context,
          builder: (final dCtx) => HookConsumer(
            builder: (final hCtx, final ref, final child) {
              final categories = ref.watch(categoriesProvider);
              final currentUri = GoRouterState.of(context).pathParameters;
              final ModCategory? initialCategory;
              if (currentUri.containsKey('category')) {
                final categoryName = currentUri['category']!;
                initialCategory = categories.firstWhereOrNull(
                  (final e) => e.name == categoryName,
                );
              } else {
                initialCategory = null;
              }
              final currentSelected = useState<ModCategory?>(initialCategory);
              return ContentDialog(
                title: const Text('Protocol URL received'),
                content: IntrinsicHeight(
                  child: ComboboxFormField<ModCategory>(
                    value: currentSelected.value,
                    items: categories
                        .map(
                          (final e) => ComboBoxItem(
                            value: e,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (final value) {
                      currentSelected.value = value;
                    },
                    validator: (final value) =>
                        value == null ? 'Please select a category' : null,
                    autovalidateMode: AutovalidateMode.always,
                  ),
                ),
                actions: [
                  Button(
                    onPressed: Navigator.of(dCtx).pop,
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: currentSelected.value == null
                        ? null
                        : () async {
                            final nahida = ref.read(nahidaApiProvider);
                            var uuid = Uri.parse(url).queryParameters['uuid'];
                            if (uuid == null) {
                              return;
                            }
                            // if uuid has no dashes, add it manually
                            if (uuid.length == 32) {
                              final sb = StringBuffer()
                                ..writeAll(
                                  [
                                    uuid.substring(0, 8),
                                    uuid.substring(8, 12),
                                    uuid.substring(12, 16),
                                    uuid.substring(16, 20),
                                    uuid.substring(20, 32),
                                  ],
                                  '-',
                                );
                              uuid = sb.toString();
                            }
                            final elem =
                                await nahida.fetchNahidaliveElement(uuid);
                            unawaited(
                              ref
                                  .read(nahidaDownloadQueueProvider.notifier)
                                  .addDownload(
                                    element: elem,
                                    category: currentSelected.value!,
                                  ),
                            );
                            if (dCtx.mounted) {
                              Navigator.of(dCtx).pop();
                            }
                          },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          ),
        ),
      );
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

  Widget _buildAutoSuggestBox(final List<FolderPaneItem> items) =>
      AutoSuggestBox2(
        items: items
            .map(
              (final e) => AutoSuggestBoxItem2(
                value: e.category,
                label: e.category.name,
              ),
            )
            .toList(),
        trailingIcon: const Icon(FluentIcons.search),
        onSelected: (final item) {
          final category = item.value;
          if (category == null) {
            return;
          }
          context.go('${RouteNames.category.name}/${category.name}');
        },
        onSubmissionFailed: (final text) {
          if (text.isEmpty) {
            return;
          }
          final item = items.firstWhereOrNull((final e) {
            final name = e.category.name.toLowerCase();
            return name.startsWith(text.toLowerCase());
          });
          if (item == null) {
            return;
          }
          final category = item.category;
          context.go('${RouteNames.category.name}/${category.name}');
        },
      );

  NavigationPane _buildPane() {
    final items = ref
        .watch(categoriesProvider)
        .map(
          (final e) => FolderPaneItem(
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
      autoSuggestBox: _buildAutoSuggestBox(items),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
    );
  }

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    final select = ref.watch(runTogetherProvider);
    final override = ref.watch(separateRunOverrideProvider);
    return override ?? select
        ? [
            RunAndExitPaneAction(
              key: const Key('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: _runBoth,
              flyoutController: _flyoutController,
            ),
          ]
        : [
            RunAndExitPaneAction(
              key: const Key('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: _runMigoto,
              flyoutController: _flyoutController,
            ),
            RunAndExitPaneAction(
              key: const Key('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: _runLauncher,
              flyoutController: _flyoutController,
            ),
          ];
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

  Future<void> _runBoth() async {
    await _runMigoto();
    await _runLauncher();
  }

  Future<void> _runLauncher() async {
    final launcher = ref.read(gameConfigNotifierProvider).launcherFile;
    if (launcher == null) {
      return;
    }
    await _runProgram(launcher);
  }

  Future<void> _runMigoto() async {
    final path = ref.read(gameConfigNotifierProvider).modExecFile;
    if (path == null) {
      return;
    }
    await _runProgram(path);
    if (mounted) {
      await displayInfoBarInContext(context,
          title: const Text('Ran 3d migoto'));
    }
  }

  Future<void> _runProgram(final String path) async {
    final file = File(path);
    final pwd = file.parent.path;
    final pName = file.path.pBasename;
    await Process.run('start', ['/b', '/d', pwd, '', pName], runInShell: true);
  }

  void _showNahidaApiErrorInfoBar(
    final HttpException exception,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Download failed'),
        content: Text('${exception.uri}'),
        severity: InfoBarSeverity.error,
      ),
    );
  }

  void _showNahidaDownloadCompleteInfoBar(
    final NahidaliveElement element,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: Text('Downloaded ${element.title}'),
        severity: InfoBarSeverity.success,
      ),
    );
  }

  Future<void> _showNahidaWrongPasswdDialog(
    final Completer<String?> completer,
    final String? wrongPw,
  ) async {
    final userResponse = await showDialog<String?>(
      context: context,
      builder: (final dialogContext) => ContentDialog(
        title: const Text('Enter password'),
        content: IntrinsicHeight(
          child: TextFormBox(
            autovalidateMode: AutovalidateMode.always,
            autofocus: true,
            controller: _textEditingController,
            placeholder: 'Password',
            onFieldSubmitted: (final value) =>
                Navigator.of(dialogContext).pop(_textEditingController.text),
            validator: (final value) {
              if (wrongPw == null || value == null) {
                return null;
              }
              if (value == wrongPw) {
                return 'Wrong password';
              }
              return null;
            },
          ),
        ),
        actions: [
          Button(
            onPressed: Navigator.of(dialogContext).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_textEditingController.text),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    completer.complete(userResponse);
  }

  Future<void> _showNahidaZipExtractionErrorInfoBar(
    final NahidaliveElement element,
    final ModCategory category,
    final Uint8List data,
  ) async {
    var writeSuccess = false;
    Exception? exception;
    final fileName = '${element.title}.zip';
    try {
      await File(category.path.pJoin(fileName)).writeAsBytes(data);
      writeSuccess = true;
    } on Exception catch (e) {
      writeSuccess = false;
      exception = e;
    }
    if (mounted) {
      final contentString = switch (writeSuccess) {
        true => 'Failed to extract archive. '
            'Instead, the archive was saved as $fileName.',
        false => 'Failed to extract archive. '
            'During an attempt to save the archive, '
            'an exception has occurred: $exception',
      };
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Download failed'),
          content: Text(contentString),
          severity: InfoBarSeverity.error,
          duration: const Duration(seconds: 30),
        ),
      );
    }
  }

  Future<Q?> _showInvalidCommandDialog<Q extends Object?>(final String arg) =>
      showDialog<Q>(
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
      );

  Future<bool?> _showUpdateConfirmDialog() => showDialog<bool?>(
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
              onPressed: () => Navigator.of(dialogContext).pop(true),
            );
          }

          return ContentDialog(
            title: const Text('Start auto update?'),
            content: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: 'This will download the latest version'
                        ' and replace the current one.'
                        ' This feature is experimental'
                        ' and may not work as expected.\n',
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
            ),
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
      );

  Future<void> _showUpdateInfoBar(final String newVersion) =>
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
          onPressed: () async {
            final result = await _showUpdateConfirmDialog();
            if (result ?? false) {
              await _runUpdateScript();
            }
          },
          child: const Text('Auto update'),
        ),
      );
}
