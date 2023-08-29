import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../base/directory_watch_widget.dart';
import '../io/fsops.dart';
import '../provider/app_state.dart';
import 'page/folder.dart';
import 'page/setting.dart';

class HomeWindow extends MultiDirectoryWatchWidget {
  const HomeWindow({
    super.key,
    required super.dirPaths,
  });

  @override
  MDWState<HomeWindow> createState() => _HomeWindowState();
}

class _HomeWindowState extends MDWState<HomeWindow> with WindowListener {
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
  bool shouldUpdate(int index, FileSystemEvent event) {
    logger.d('$this update: $index, $event');
    if (index == -1 || index == 0) {
      return !(event is FileSystemModifyEvent && event.contentChanged);
    } else if (index == -1 || index == 1) {
      return true;
    }
    return false;
  }

  @override
  void updateFolder(int updateIndex) {
    logger.d('$this updateFolder: $updateIndex');
    if (updateIndex == -1 || updateIndex == 0) {
      final dir = widget.dir(0);
      final sel_ = selected;
      Key? selectedFolder;
      if (sel_ != null && sel_ < subFolders.length) {
        selectedFolder = subFolders[sel_].key;
      }
      subFolders = [];
      final List<Directory> allFolder;
      try {
        allFolder = getFoldersUnder(dir);
      } on PathNotFoundException {
        logger.e('Path not found: $dir');
        return;
      }
      for (final element in allFolder) {
        final folderName = p.basename(element.path).toLowerCase();
        final previewFile = findPreviewFile(widget.dir(1), name: folderName);
        if (previewFile != null) {
          logger.d('Preview file for $folderName: $previewFile');
        }
        subFolders.add(FolderPaneItem(
          dirPath: element.path,
          imageFile: previewFile,
        ));
      }
      logger.d('Home subfolders: $subFolders');
      if (selectedFolder == null) return;
      final index = subFolders.indexWhere((e) => e.key == selectedFolder);
      if (index == -1) return;
      selected = index;
    } else if (updateIndex == -1 || updateIndex == 1) {
      final List<NavigationPaneItem> updateFolder = [];
      for (final element in subFolders) {
        final fpelem = element as FolderPaneItem;
        final folderName = p.basename(fpelem.dirPath).toLowerCase();
        final previewFile = findPreviewFile(widget.dir(1), name: folderName);
        if (previewFile != null) {
          logger.d('Preview file for $folderName: $previewFile');
        }
        updateFolder.add(
          FolderPaneItem(
            dirPath: fpelem.dirPath,
            imageFile: previewFile,
          ),
        );
      }
      subFolders = updateFolder;
    }
  }
}

class FolderPaneItem extends PaneItem {
  static final logger = Logger();
  String dirPath;

  FolderPaneItem({
    required this.dirPath,
    File? imageFile,
  }) : super(
          title: Text(
            p.basename(dirPath),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: Selector<AppState, bool>(
            selector: (_, appState) => appState.showFolderIcon,
            builder: (context, value, child) {
              if (value) {
                const size = 80.0;
                return ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(size, size)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageFile != null
                        ? Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          )
                        : Image.asset('images/app_icon.ico'),
                  ),
                );
              } else {
                return const Icon(FluentIcons.folder_open);
              }
            },
          ),
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
        dropFinishHandler(context, details, logger, dirPath);
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
