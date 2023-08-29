import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:genshin_mod_manager/window/page/folder.dart';
import 'package:genshin_mod_manager/window/page/setting.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HomeWindow extends MultiDirectoryWatchWidget {
  const HomeWindow({
    super.key,
    required super.dirPaths,
  });

  @override
  MDWState<HomeWindow> createState() => _HomeWindowState();
}

class _HomeWindowState extends MDWState<HomeWindow> with WindowListener {
  static const navigationPaneOpenWidth = 270.0;
  static const PathString exeName = PathString('3DMigoto Loader.exe');
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
    return NavigationPane(
      selected: selected,
      onChanged: (i) {
        logger.d('Selected $i th PaneItem');
        setState(() => selected = i);
      },
      displayMode: PaneDisplayMode.auto,
      size: const NavigationPaneSize(openWidth: navigationPaneOpenWidth),
      autoSuggestBox: buildAutoSuggestBox(),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
      items: subFolders,
      footerItems: [
        PaneItemSeparator(),
        ...buildPaneItemActions(context),
        PaneItem(
          icon: const Icon(FluentIcons.settings),
          title: const Text('Settings'),
          body: const SettingPage(),
        ),
      ],
    );
  }

  List<PaneItemAction> buildPaneItemActions(BuildContext context) {
    const icon = Icon(FluentIcons.user_window);
    return context.select<AppState, bool>((value) => value.runTogether)
        ? [
            PaneItemAction(
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: () {
                runMigoto(context);
                runLauncher(context);
              },
            ),
          ]
        : [
            PaneItemAction(
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: () => runMigoto(context),
            ),
            PaneItemAction(
              icon: icon,
              title: const Text('Run launcher'),
              onTap: () => runLauncher(context),
            ),
          ];
  }

  AutoSuggestBox<Key> buildAutoSuggestBox() {
    return AutoSuggestBox(
      items: subFolders
          .map((e) => AutoSuggestBoxItem(
                value: e.key,
                label: (e as FolderPaneItem).dirPath.basename.asString,
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
      final dir = widget.dirPaths[0].toDirectory;
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
        final folderName = element.basename;
        final previewFile =
            findPreviewFile(widget.dirPaths[1].toDirectory, name: folderName);
        if (previewFile != null) {
          logger.d('Preview file for $folderName: $previewFile');
        }
        subFolders.add(FolderPaneItem(
          dirPath: element.pathString,
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
        final folderName = fpelem.dirPath.basename;
        final previewFile =
            findPreviewFile(widget.dirPaths[1].toDirectory, name: folderName);
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

  void runMigoto(BuildContext context) {
    final tDir = context.read<AppState>().targetDir;
    final path = tDir.join(exeName);
    runProgram(path.toFile);
    logger.t('Ran 3d migoto $path');
  }

  void runLauncher(BuildContext context) {
    final launcher = context.read<AppState>().launcherFile;
    runProgram(launcher.toFile);
    logger.t('Ran launcher $launcher');
  }
}

class FolderPaneItem extends PaneItem {
  static const maxIconSize = 80.0;
  static final logger = Logger();

  static Selector<AppState, bool> _getIcon(File? imageFile) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.showFolderIcon,
      builder: (context, value, child) {
        if (!value) return const Icon(FluentIcons.folder_open);
        return buildImage(imageFile);
      },
    );
  }

  static Widget buildImage(File? imageFile) {
    final Image image;
    if (imageFile == null) {
      image = Image.asset('images/app_icon.ico');
    } else{
      image = Image.file(
        imageFile,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    return SizedBox(
      width: maxIconSize,
      height: maxIconSize,
      child: image,
    );
  }

  PathString dirPath;

  FolderPaneItem({
    required this.dirPath,
    File? imageFile,
  }) : super(
          title: Text(
            dirPath.basename.asString,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _getIcon(imageFile),
          body: FolderPage(dirPath: dirPath),
          key: ValueKey(dirPath),
        );

  @override
  Widget build(BuildContext context, bool selected, VoidCallback? onPressed,
      {PaneDisplayMode? displayMode,
      bool showTextOnTop = true,
      int? itemIndex,
      bool? autofocus}) {
    return FolderDropTarget(
      dirPath: dirPath,
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
