import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/service/preset_service.dart';
import 'package:genshin_mod_manager/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:genshin_mod_manager/third_party/fluent_ui/red_filled_button.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class HomeShell extends StatelessWidget {
  static const resourceDir = PathW('Resources');
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final modResourcePath = PathW(Platform.resolvedExecutable)
        .dirname
        .join(resourceDir)
        .toDirectory
      ..createSync();
    return Selector<AppStateService, PathW>(
      selector: (p0, p1) => p1.modRoot,
      builder: (BuildContext context, PathW modRootValue, Widget? child2) {
        return MultiProvider(
          key: Key(modRootValue.asString),
          providers: [
            ChangeNotifierProvider(
              create: (context) => CategoryIconFolderObserverService(
                targetDir: modResourcePath,
              ),
            ),
            ChangeNotifierProvider(
              create: (context) => RecursiveObserverService(
                targetDir: modRootValue.toDirectory,
              ),
            ),
            ChangeNotifierProxyProvider2<AppStateService,
                RecursiveObserverService, PresetService>(
              create: (context) => PresetService(),
              update: (context, value, value2, previous) =>
                  previous!..update(value, value2),
            ),
          ],
          child: DirWatchProvider(
            dir: modRootValue.toDirectory,
            child: _HomeShell(child: child),
          ),
        );
      },
    );
  }
}

class _HomeShell extends StatefulWidget {
  final Widget child;

  const _HomeShell({required this.child});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState<T extends StatefulWidget> extends State<_HomeShell> {
  static const _navigationPaneOpenWidth = 270.0;
  static final _logger = Logger();

  final textEditingController = TextEditingController();

  bool updateDisplayed = false;

  Future<void> _checkUpdate() async {
    const baseLink =
        'https://github.com/traveling-lumine/genshin_mod_manager/releases/latest';
    final url = Uri.parse(baseLink);
    final client = http.Client();
    final request = http.Request('GET', url)..followRedirects = false;
    final upstreamVersion = client.send(request).then((value) {
      final location = value.headers['location'];
      if (location == null) return null;
      final lastSlash = location.lastIndexOf('tag/v');
      if (lastSlash == -1) return null;
      return location.substring(lastSlash + 5, location.length);
    });
    final currentVersion =
        PackageInfo.fromPlatform().then((value) => value.version);
    final List<String?> versions =
        await Future.wait([upstreamVersion, currentVersion]);
    final upVersion = versions[0];
    final curVersion = versions[1];
    if (upVersion == null || curVersion == null) return;
    final upstream =
        upVersion.split('.').map(int.parse).toList(growable: false);
    final current =
        curVersion.split('.').map(int.parse).toList(growable: false);
    bool shouldUpdate = false;
    for (var i = 0; i < 3; i++) {
      if (upstream[i] > current[i]) {
        shouldUpdate = true;
        break;
      } else if (upstream[i] < current[i]) {
        break;
      }
    }
    if (!shouldUpdate) return;
    if (!context.mounted) return;
    unawaited(displayInfoBar(
      context,
      duration: const Duration(minutes: 1),
      builder: (_, close) => InfoBar(
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(text: 'New version available: '),
              TextSpan(
                text: upVersion,
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
                  ..onTap = () => launchUrl(url),
              ),
              const TextSpan(text: ' to open link.'),
            ],
          ),
        ),
        action: FilledButton(
          onPressed: () async {
            unawaited(showDialog(
              context: context,
              builder: (context2) => ContentDialog(
                title: const Text('Start auto update?'),
                content: RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text:
                            'This will download the latest version and replace the current one.'
                            ' This feature is experimental and may not work as expected.\n',
                        // justify
                      ),
                      TextSpan(
                        text:
                            'Please backup your mods and resources before proceeding.\nDELETION OF UNRELATED FILES IS POSSIBLE.',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Button(
                    child: const Text('Cancel'),
                    onPressed: () {
                      context2.pop();
                    },
                  ),
                  RedFilledButton(
                    child: const Text('Start'),
                    onPressed: () async {
                      context2.pop();
                      final url =
                          Uri.parse('$baseLink/download/GenshinModManager.zip');
                      final response = await http.get(url);
                      final archive =
                          ZipDecoder().decodeBytes(response.bodyBytes);
                      for (final aFile in archive) {
                        final path = '${Directory.current.path}/${aFile.name}';
                        if (aFile.isFile) {
                          await File(path).writeAsBytes(aFile.content);
                        } else {
                          Directory(path).createSync(recursive: true);
                        }
                      }
                      const teeScript = "call update.cmd > update.log 2>&1\n"
                          "if %errorlevel% == 1 (\n"
                          "    echo Maybe not in the mod manager folder? Exiting for safety.\n"
                          "	   pause\n"
                          ")\n"
                          "if %errorlevel% == 2 (\n"
                          "    echo Failed to download data! Go to the link and install manually.\n"
                          "	   pause\n"
                          ")\n"
                          "del update.cmd\n"
                          "start /b cmd /c del tee.cmd\n";
                      const updateScript = "setlocal\n"
                          "echo update script running\n"
                          "set \"sourceFolder=GenshinModManager\"\n"
                          "if not exist \"genshin_mod_manager.exe\" (\n"
                          "    exit /b 1\n"
                          ")\n"
                          "if not exist %sourceFolder% (\n"
                          "    exit /b 2\n"
                          ")\n"
                          "echo So it's good to go. Let's update.\n"
                          "for /f \"delims=\" %%i in ('dir /b /a-d ^| findstr /v /i \"tee.cmd update.cmd update.log error.log\"') do del \"%%i\"\n"
                          "for /f \"delims=\" %%i in ('dir /b /ad ^| findstr /v /i \"Resources %sourceFolder%\"') do rd /s /q \"%%i\"\n"
                          "for /f \"delims=\" %%i in ('dir /b \"%sourceFolder%\"') do move /y \"%sourceFolder%\\%%i\" .\n"
                          "rd /s /q %sourceFolder%\n"
                          "start genshin_mod_manager.exe\n"
                          "endlocal\n";
                      await File('tee.cmd').writeAsString(teeScript);
                      await File('update.cmd').writeAsString(updateScript);
                      unawaited(Process.run(
                        'start',
                        [
                          'cmd',
                          '/c',
                          'timeout /t 3 && call tee.cmd',
                        ],
                        runInShell: true,
                      ));
                      await Future.delayed(const Duration(milliseconds: 200));
                      exit(0);
                    },
                  ),
                ],
              ),
            ));
          },
          child: const Text('Auto update'),
        ),
        onClose: close,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!updateDisplayed) {
      updateDisplayed = true;
      unawaited(_checkUpdate());
    }

    final imageFiles =
        context.select<CategoryIconFolderObserverService, List<File>>(
            (value) => value.curFiles);
    final sortedMenus = context.select<DirWatchService, List<String>>((value) =>
        value.curDirs
            .map((e) => e.pathW.basename.asString)
            .toList(growable: false))
      ..sort(compareNatural);
    final items = sortedMenus
        .map((e) => _FolderPaneItem(
            category: e,
            imageFile: findPreviewFileIn(imageFiles, name: e.pathW),
            onTap: () => context.go('/category/$e')))
        .toList(growable: false);

    final footerItems = [
      PaneItemSeparator(),
      ..._buildPaneItemActions(),
      PaneItem(
        key: const ValueKey('/setting'),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () => context.go('/setting'),
      ),
    ];

    final effectiveItems = ((items.cast<NavigationPaneItem>() + footerItems)
          ..removeWhere((i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();
    final currentRoute = Uri.decodeFull(GoRouterState.of(context).uri.path);
    final index = effectiveItems.indexWhere((e) {
      final key = e.key;
      if (key is! ValueKey<String>) return false;
      return key.value == currentRoute;
    });
    final int? selected = index != -1 ? index : null;

    return NavigationView(
      transitionBuilder: (child, animation) =>
          SuppressPageTransition(child: child),
      appBar: _buildAppbar(),
      pane: _buildPane(selected, items, footerItems),
      paneBodyBuilder: (item, body) => widget.child,
    );
  }

  NavigationAppBar _buildAppbar() {
    return NavigationAppBar(
      actions: const RepaintBoundary(child: WindowButtons()),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: DragToMoveArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Genshin Mod Manager'),
              ),
            ),
          ),
          Row(
            children: [
              _buildPresetAddIcon(),
              const SizedBox(width: 8),
              _buildPresetSelect(),
              const SizedBox(width: 138),
            ],
          ),
        ],
      ),
    );
  }

  NavigationPane _buildPane(int? selected, List<_FolderPaneItem> items,
      List<NavigationPaneItem> footerItems) {
    return NavigationPane(
      selected: selected,
      items: items.cast<NavigationPaneItem>(),
      footerItems: footerItems,
      displayMode: PaneDisplayMode.auto,
      size: const NavigationPaneSize(
        openWidth: _HomeShellState._navigationPaneOpenWidth,
      ),
      autoSuggestBox: _buildAutoSuggestBox(items, footerItems),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
    );
  }

  Widget _buildPresetSelect() {
    return Selector<PresetService, List<String>>(
      selector: (p0, p1) => p1.getGlobalPresets(),
      builder: (context, value, child) => RepaintBoundary(
        child: ComboBox(
          items: value
              .map((e) => ComboBoxItem(value: e, child: Text(e)))
              .toList(growable: false),
          placeholder: const Text('Global Preset...'),
          onChanged: (value) => showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context2) => ContentDialog(
              title: const Text('Apply Global Preset?'),
              content: Text('Preset name: $value'),
              actions: [
                RedFilledButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.of(context2).pop();
                    context.read<PresetService>().removeGlobalPreset(value!);
                  },
                ),
                Button(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context2).pop();
                  },
                ),
                FilledButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    Navigator.of(context2).pop();
                    context.read<PresetService>().setGlobalPreset(value!);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetAddIcon() {
    return RepaintBoundary(
      child: IconButton(
        icon: const Icon(FluentIcons.add),
        onPressed: () {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context2) {
              return ContentDialog(
                title: const Text('Add Global Preset'),
                content: SizedBox(
                  height: 40,
                  child: TextBox(
                    controller: textEditingController,
                    placeholder: 'Preset Name',
                  ),
                ),
                actions: [
                  Button(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context2).pop();
                    },
                  ),
                  FilledButton(
                    child: const Text('Add'),
                    onPressed: () {
                      Navigator.of(context2).pop();
                      final text = textEditingController.text;
                      textEditingController.clear();
                      context.read<PresetService>().addGlobalPreset(text);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    return context.select<AppStateService, bool>((value) => value.runTogether)
        ? [
            PaneItemAction(
              key: const ValueKey('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: () {
                _runMigoto();
                _runLauncher();
              },
            ),
          ]
        : [
            PaneItemAction(
              key: const ValueKey('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: () => _runMigoto(),
            ),
            PaneItemAction(
              key: const ValueKey('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: () => _runLauncher(),
            ),
          ];
  }

  Widget _buildAutoSuggestBox(
      List<_FolderPaneItem> items, List<NavigationPaneItem> footerItems) {
    return AutoSuggestBox2(
      items: items
          .map((e) => AutoSuggestBoxItem2(
                value: e.key,
                label: e.category,
                onSelected: () => context.go('/category/${e.category}'),
              ))
          .toList(growable: false),
      trailingIcon: const Icon(FluentIcons.search),
      onSubmissionFailed: (text) {
        if (text.isEmpty) return;
        text = '/category/$text';
        final index = items.indexWhere((_FolderPaneItem e) {
          final name = (e.key as ValueKey<String>).value.toLowerCase();
          return name.startsWith(text.toLowerCase());
        });
        if (index == -1) return;
        final category = items[index].category;
        context.go('/category/$category');
      },
    );
  }

  void _runMigoto() {
    final path = context.read<AppStateService>().modExecFile;
    runProgram(path.toFile);
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Ran 3d migoto'),
          onClose: close,
        );
      },
    );
    _logger.t('Ran 3d migoto $path');
  }

  void _runLauncher() {
    final launcher = context.read<AppStateService>().launcherFile;
    runProgram(launcher.toFile);
    _logger.t('Ran launcher $launcher');
  }
}

class _FolderPaneItem extends PaneItem {
  static const maxIconWidth = 80.0;

  static Widget _getIcon(File? imageFile) {
    return Selector<AppStateService, bool>(
      selector: (_, service) => service.showFolderIcon,
      builder: (_, value, __) =>
          value ? _buildImage(imageFile) : const Icon(FluentIcons.folder_open),
    );
  }

  static Widget _buildImage(File? imageFile) {
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

  String category;

  _FolderPaneItem({
    required this.category,
    super.onTap,
    File? imageFile,
  }) : super(
          key: Key('/category/$category'),
          title: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _getIcon(imageFile),
          body: const SizedBox.shrink(),
        );

  @override
  Widget build(BuildContext context, bool selected, VoidCallback? onPressed,
      {PaneDisplayMode? displayMode,
      bool showTextOnTop = true,
      int? itemIndex,
      bool? autofocus}) {
    return FolderDropTarget(
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
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('category', category));
  }
}
