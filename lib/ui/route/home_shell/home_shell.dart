import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:genshin_mod_manager/data/constant.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem.dart';
import 'package:genshin_mod_manager/data/repo/preset.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/route/home_shell/home_shell_vm.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/widget/appbar.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control/preset_control.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/red_filled_button.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

const _kRepoReleases = '$kRepoBase/releases/latest';

class HomeShell extends StatelessWidget {
  static const resourceDir = 'Resources';
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final resourcePath =
        Platform.resolvedExecutable.pDirname.pJoin(resourceDir);
    Directory(resourcePath).createSync(recursive: true);
    final modRootPath =
        context.select((AppStateService value) => value.modRoot);
    return MultiProvider(
      key: Key(modRootPath),
      providers: [
        Provider(
          create: (context) => createRecursiveFileSystemWatchService(
            targetPath: modRootPath,
          ),
          dispose: (context, value) => value.dispose(),
        ),
        ChangeNotifierProxyProvider2<AppStateService, RecursiveFSWatchService,
            PresetService>(
          create: (context) => PresetService(),
          update: (context, value, value2, previous) =>
              previous!..update(value, value2),
        ),
        ChangeNotifierProvider(
          create: (context) => createViewModel(
            appStateService: context.read(),
            recursiveObserverService: context.read(),
          ),
        ),
      ],
      child: _HomeShell(child: child),
    );
  }
}

class _HomeShell extends StatefulWidget {
  final Widget child;

  const _HomeShell({required this.child});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState<T extends StatefulWidget> extends State<_HomeShell>
    with WindowListener {
  static const _navigationPaneOpenWidth = 270.0;

  bool updateDisplayed = false;

  @override
  void onWindowFocus() {
    final vm = context.read<HomeShellViewModel>();
    vm.onWindowFocus();
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
  Widget build(BuildContext context) {
    if (!updateDisplayed) {
      updateDisplayed = true;
      _shouldUpdate(context).then((value) {
        if (value == null) return;
        if (!context.mounted) return;
        return _displayUpdateInfoBar(value);
      });
    }

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

    final categories =
        context.select((HomeShellViewModel vm) => vm.modCategories);
    final items = categories.map((e) {
      final iconPath = e.iconPath;
      return _FolderPaneItem(
          category: e,
          imageFile: iconPath != null ? File(iconPath) : null,
          onTap: () => context.go(kCategoryRoute, extra: e));
    }).toList(growable: false);

    final effectiveItems = ((items.cast<NavigationPaneItem>() + footerItems)
          ..removeWhere((i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();

    final currentRouteExtra = GoRouterState.of(context).extra;
    final index = effectiveItems.indexWhere((e) {
      final key = e.key;
      if (key is! ValueKey<ModCategory>) return false;
      return key.value == currentRouteExtra;
    });

    final int? selected = index != -1 ? index : null;

    final uri = GoRouterState.of(context).uri;
    final uriSegments = uri.pathSegments;
    if (uriSegments.length == 1 &&
        uriSegments[0] == 'category' &&
        !categories.any((e) => e == currentRouteExtra)) {
      final String destination;
      final ModCategory? extra;
      if (categories.isNotEmpty) {
        final index = _search(categories, currentRouteExtra as ModCategory);
        destination = kCategoryRoute;
        extra = categories[index];
      } else {
        destination = kHomeRoute;
        extra = null;
      }
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        context.go(destination, extra: extra);
      });
    }

    return NavigationView(
      transitionBuilder: (child, animation) =>
          SuppressPageTransition(child: child),
      appBar: _buildAppbar(),
      pane: _buildPane(selected, items, footerItems),
      paneBodyBuilder: (item, body) => widget.child,
    );
  }

  void _displayUpdateInfoBar(String newVersion) {
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
                ..onTap = () => launchUrl(Uri.parse(_kRepoReleases)),
            ),
            const TextSpan(text: ' to open link.'),
          ],
        ),
      ),
      action: FilledButton(
        onPressed: () => showDialog(
          context: context,
          builder: (dialogContext) => ContentDialog(
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
                        'Please backup your mods and resources before proceeding.\n'
                        'DELETION OF UNRELATED FILES IS POSSIBLE.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: Navigator.of(dialogContext).pop,
                child: const Text('Cancel'),
              ),
              RedFilledButton(
                child: const Text('Start'),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _runUpdateScript();
                },
              ),
            ],
          ),
        ),
        child: const Text('Auto update'),
      ),
    );
  }

  NavigationAppBar _buildAppbar() {
    return NavigationAppBar(
      actions: const WindowButtons(),
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
              PresetControlWidget(isLocal: false),
              const SizedBox(width: kWindowButtonWidth),
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

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    return context.select((HomeShellViewModel vm) => vm.runTogether)
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

  void _runLauncher() {
    final vm = context.read<HomeShellViewModel>();
    vm.runLauncher();
  }

  void _runBoth() {
    _runMigoto();
    _runLauncher();
  }

  void _runMigoto() {
    final vm = context.read<HomeShellViewModel>();
    vm.runMigoto();
    displayInfoBarInContext(
      context,
      title: const Text('Ran 3d migoto'),
    );
  }

  Widget _buildAutoSuggestBox(
      List<_FolderPaneItem> items, List<NavigationPaneItem> footerItems) {
    return AutoSuggestBox2(
      items: items
          .map((e) => AutoSuggestBoxItem2(
                value: e.key,
                label: e.category.name,
                onSelected: () => context.go(kCategoryRoute, extra: e.category),
              ))
          .toList(growable: false),
      trailingIcon: const Icon(FluentIcons.search),
      onSubmissionFailed: (text) {
        if (text.isEmpty) return;
        final index = items.indexWhere((_FolderPaneItem e) {
          final name =
              (e.key as ValueKey<ModCategory>).value.name.toLowerCase();
          return name.startsWith(text.toLowerCase());
        });
        if (index == -1) return;
        final category = items[index].category;
        context.go(kCategoryRoute, extra: category);
      },
    );
  }
}

class _FolderPaneItem extends PaneItem {
  static const maxIconWidth = 80.0;

  static Widget _getIcon(File? imageFile) {
    return Selector<HomeShellViewModel, bool>(
      selector: (context, value) => value.showFolderIcon,
      builder: (context, value, child) =>
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

  ModCategory category;

  _FolderPaneItem({
    required this.category,
    super.onTap,
    File? imageFile,
  }) : super(
          key: ValueKey(category),
          title: Text(
            category.name,
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
    return CategoryDropTarget(
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
}

Future<String?> _shouldUpdate(BuildContext context) async {
  final url = Uri.parse(_kRepoReleases);
  List<String?> versions = await _getVersions(url);
  final upVersion = versions[0];
  final curVersion = versions[1];
  if (upVersion == null || curVersion == null) return null;
  return _compareVersions(upVersion, curVersion) ? upVersion : null;
}

Future<List<String?>> _getVersions(Uri url) async {
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
  return await Future.wait([upstreamVersion, currentVersion]);
}

bool _compareVersions(String upVersion, String curVersion) {
  final upstream = upVersion.split('.').map(int.parse).toList(growable: false);
  final current = curVersion.split('.').map(int.parse).toList(growable: false);
  bool shouldUpdate = false;
  for (var i = 0; i < 3; i++) {
    if (upstream[i] > current[i]) {
      shouldUpdate = true;
      break;
    } else if (upstream[i] < current[i]) {
      break;
    }
  }
  return shouldUpdate;
}

Future<void> _runUpdateScript() async {
  final url = Uri.parse('$_kRepoReleases/download/GenshinModManager.zip');
  final response = await http.get(url);
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  await extractArchiveToDiskAsync(archive, Directory.current.path,
      asyncWrite: true);
  const updateScript = "setlocal\n"
      "echo update script running\n"
      "set \"sourceFolder=GenshinModManager\"\n"
      "if not exist \"genshin_mod_manager.exe\" (\n"
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
  unawaited(Process.run(
    'start',
    [
      'cmd',
      '/c',
      'timeout /t 3 && call update.cmd > update.log',
    ],
    runInShell: true,
  ));
  await Future.delayed(const Duration(milliseconds: 200));
  exit(0);
}

int _search(List<ModCategory> categories, ModCategory category) {
  final length = categories.length;
  int lo = 0;
  int hi = length;
  while (lo < hi) {
    int mid = lo + ((hi - lo) >> 1);
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
