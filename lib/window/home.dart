import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/window/page/folder.dart';
import 'package:genshin_mod_manager/window/page/setting.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HomeWindow extends DirectoryWatchWidget {
  const HomeWindow({
    super.key,
    required super.dirPath,
  });

  @override
  DWState<HomeWindow> createState() => _HomeWindowState();
}

class _HomeWindowState extends DWState<HomeWindow> with WindowListener {
  static final Logger logger = Logger();
  late List<NavigationPaneItem> subFolders;
  int? selected;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      transitionBuilder: (child, animation) {
        return SuppressPageTransition(child: child);
      },
      appBar: buildNavigationAppBar(),
      pane: buildNavigationPane(context),
    );
  }

  NavigationAppBar buildNavigationAppBar() {
    return const NavigationAppBar(
      actions: WindowButtons(),
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Genshin Mod Manager'),
        ),
      ),
    );
  }

  NavigationPane buildNavigationPane(BuildContext context) {
    final List<PaneItemAction> paneItemActions;
    if (context.select<AppState, bool>((value) => value.runTogether)) {
      paneItemActions = [
        PaneItemAction(
          icon: const Icon(FluentIcons.user_window),
          title: const Text('Run 3d migoto & launcher'),
          onTap: () {
            final tDir = context.read<AppState>().targetDir;
            final launcher = context.read<AppState>().launcherFile;
            final path = p.join(tDir, '3DMigoto Loader.exe');
            runProgram(File(path));
            logger.t('Ran 3d migoto $path');
            runProgram(File(launcher));
            logger.t('Ran launcher $launcher');
          },
        ),
      ];
    } else {
      paneItemActions = [
        PaneItemAction(
          icon: const Icon(FluentIcons.user_window),
          title: const Text('Run 3d migoto'),
          onTap: () {
            final tDir = context.read<AppState>().targetDir;
            final path = p.join(tDir, '3DMigoto Loader.exe');
            runProgram(File(path));
            logger.t('Ran 3d migoto $path');
          },
        ),
        PaneItemAction(
          icon: const Icon(FluentIcons.user_window),
          title: const Text('Run launcher'),
          onTap: () {
            final launcher = context.read<AppState>().launcherFile;
            runProgram(File(launcher));
            logger.t('Ran launcher $launcher');
          },
        ),
      ];
    }
    return NavigationPane(
      selected: selected,
      onChanged: (i) {
        logger.d('Selected $i th PaneItem');
        setState(() => selected = i);
      },
      displayMode: PaneDisplayMode.auto,
      size: const NavigationPaneSize(openWidth: 300),
      autoSuggestBox: buildAutoSuggestBox(),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
      items: subFolders,
      footerItems: [
        PaneItemSeparator(),
        ...paneItemActions,
        PaneItem(
          icon: const Icon(FluentIcons.settings),
          title: const Text('Settings'),
          body: const SettingPage(),
        ),
      ],
    );
  }

  AutoSuggestBox<Key> buildAutoSuggestBox() {
    return AutoSuggestBox(
      items: subFolders
          .map((e) => AutoSuggestBoxItem(
                value: e.key,
                label: p.basename((e as FolderPaneItem).dirPath),
              ))
          .toList(),
      trailingIcon: const Icon(FluentIcons.search),
      onSelected: (item) {
        setState(() {
          selected = subFolders.indexWhere((e) => e.key == item.value);
        });
      },
    );
  }

  @override
  bool shouldUpdate(FileSystemEvent event) =>
      !(event is FileSystemModifyEvent && event.contentChanged);

  @override
  void updateFolder() {
    final dir = widget.dir;
    final sel_ = selected;
    Key? selectedFolder;
    if (sel_ != null && sel_ < subFolders.length) {
      selectedFolder = subFolders[sel_].key;
    }
    subFolders = [];
    final List<Directory> allFolder;
    try {
      allFolder = getAllChildrenFolder(dir);
    } on PathNotFoundException {
      logger.e('Path not found: $dir');
      return;
    }
    for (var element in allFolder) {
      subFolders.add(FolderPaneItem(dirPath: element.path));
    }
    logger.i('Home subfolders: $subFolders');
    if (selectedFolder == null) return;
    final index = subFolders.indexWhere((e) => e.key == selectedFolder);
    if (index == -1) return;
    selected = index;
  }
}

class FolderPaneItem extends PaneItem {
  static final logger = Logger();
  String dirPath;

  FolderPaneItem({
    required this.dirPath,
  }) : super(
          title: Text(p.basename(dirPath)),
          icon: Image.asset('images/app_icon.ico'),
          body: FolderPage(dirPath: dirPath),
          key: ValueKey(dirPath),
        );

  @override
  Widget build(BuildContext context, bool selected, VoidCallback? onPressed,
      {PaneDisplayMode? displayMode,
      bool showTextOnTop = true,
      int? itemIndex,
      bool? autofocus}) {
    return DropTarget(
      onDragDone: (details) {
        final moveInsteadOfCopy = context.read<AppState>().moveOnDrag;
        for (final xFile in details.files) {
          final path = xFile.path;
          if (!FileSystemEntity.isDirectorySync(path)) continue;
          logger.d('Dragged $path');
          final dir = Directory(path);
          final newPath = p.join(dirPath, p.basename(path));
          if (moveInsteadOfCopy) {
            try {
              dir.renameSync(newPath);
              logger.d('Moved $path to $newPath');
            } on PathExistsException {
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Folder already exists'),
                    severity: InfoBarSeverity.warning,
                    onClose: close,
                  );
                },
              );
            }
          } else {
            try {
              copyDirectorySync(dir, newPath);
              logger.d('Copied $path to $newPath');
            } on PathExistsException {
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Folder already exists'),
                    severity: InfoBarSeverity.warning,
                    onClose: close,
                  );
                },
              );
            }
          }
        }
      },
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($dirPath)';
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(),
    );
  }
}
