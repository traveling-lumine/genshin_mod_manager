import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:genshin_mod_manager/window/page/folder.dart';
import 'package:genshin_mod_manager/window/page/setting.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomeWindow extends StatefulWidget {
  final List<PathW> dirPaths;

  const HomeWindow({
    super.key,
    required this.dirPaths,
  });

  @override
  State<HomeWindow> createState() => _HomeWindowState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($dirPaths)';
  }
}

class _HomeWindowState<T extends StatefulWidget> extends State<HomeWindow> {
  static const navigationPaneOpenWidth = 270.0;
  static final Logger logger = Logger();

  late final List<StreamSubscription<FileSystemEvent>> subscriptions;
  late List<NavigationPaneItem> subFolders;
  int? selected;

  @override
  void initState() {
    super.initState();
    _onUpdate(null);
    logger.t('$this is initialized');
  }

  @override
  void didUpdateWidget(covariant HomeWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.dirPaths.length == widget.dirPaths.length,
        'Directory count changed');
    var shouldUpdate = false;
    final List<int> updateIndices = [];
    for (var i = 0; i < widget.dirPaths.length; i++) {
      final oldDir = oldWidget.dirPaths[i];
      final newDir = widget.dirPaths[i];
      if (oldDir == newDir) continue;
      logger.t('Directory path changed from $oldDir to $newDir');
      subscriptions[i].cancel();
      updateIndices.add(i);
      shouldUpdate = true;
    }
    if (shouldUpdate) {
      _onUpdate(updateIndices);
    }
  }

  @override
  void dispose() {
    logger.t('$this bids you a goodbye');
    for (final element in subscriptions) {
      element.cancel();
    }
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
    return getAppbar('Genshin Mod Manager');
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
    return context.select<AppStateService, bool>((value) => value.runTogether)
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

  Widget buildAutoSuggestBox() {
    return AutoSuggestBox2(
      items: subFolders
          .map((e) => AutoSuggestBoxItem2(
                value: e.key,
                label: (e as _FolderPaneItem).dirPath.basename.asString,
              ))
          .toList(),
      trailingIcon: const Icon(FluentIcons.search),
      onSelected: (item) {
        setState(() {
          selected = subFolders.indexWhere((e) => e.key == item.value);
        });
      },
      onSubmissionFailed: (text) {
        if (text.isEmpty) return;
        test(e) {
          final name = (e.key as ValueKey<PathW>)
              .value
              .basename
              .asString
              .toLowerCase();
          return name.startsWith(text.toLowerCase());
        }

        final index = subFolders.indexWhere(test);
        if (index == -1) return;
        setState(() => selected = index);
      },
    );
  }

  bool shouldUpdate(int index, FileSystemEvent event) {
    logger.d('$this update: $index, $event');
    if (index == -1 || index == 0) {
      return !(event is FileSystemModifyEvent && event.contentChanged);
    } else if (index == -1 || index == 1) {
      return true;
    }
    return false;
  }

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
        allFolder = getDirsUnder(dir);
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
        subFolders.add(_FolderPaneItem(
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
        final fpelem = element as _FolderPaneItem;
        final folderName = fpelem.dirPath.basename;
        final previewFile =
            findPreviewFile(widget.dirPaths[1].toDirectory, name: folderName);
        if (previewFile != null) {
          logger.d('Preview file for $folderName: $previewFile');
        }
        updateFolder.add(
          _FolderPaneItem(
            dirPath: fpelem.dirPath,
            imageFile: previewFile,
          ),
        );
      }
      subFolders = updateFolder;
    }
  }

  void _onUpdate(List<int>? updates) {
    updateFolder(-1);
    if (updates == null) {
      subscriptions = [];
      for (var index = 0; index < widget.dirPaths.length; index++) {
        subscriptions
            .add(widget.dirPaths[index].toDirectory.watch().listen((event) {
          logger.d('$this update: $event');
          if (shouldUpdate(index, event)) {
            logger.d('$this update accepted');
            setState(() => updateFolder(index));
          } else {
            logger.d('$this update rejected');
          }
        }));
      }
    } else {
      for (final index in updates) {
        subscriptions[index] =
            widget.dirPaths[index].toDirectory.watch().listen((event) {
          logger.d('$this update: $event');
          if (shouldUpdate(index, event)) {
            logger.d('$this update accepted');
            setState(() => updateFolder(index));
          } else {
            logger.d('$this update rejected');
          }
        });
      }
    }
  }

  void runMigoto(BuildContext context) {
    final path = context.read<AppStateService>().modExecFile;
    runProgram(path.toFile);
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
            title: const Text('Ran 3d migoto'),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ));
      },
    );
    logger.t('Ran 3d migoto $path');
  }

  void runLauncher(BuildContext context) {
    final launcher = context.read<AppStateService>().launcherFile;
    runProgram(launcher.toFile);
    logger.t('Ran launcher $launcher');
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($widget)';
  }
}

class _FolderPaneItem extends PaneItem {
  static const maxIconWidth = 80.0;

  static Selector<AppStateService, bool> _getIcon(File? imageFile) {
    return Selector<AppStateService, bool>(
      selector: (_, service) => service.showFolderIcon,
      builder: (_, value, __) {
        return value
            ? buildImage(imageFile)
            : const Icon(FluentIcons.folder_open);
      },
    );
  }

  static Widget buildImage(File? imageFile) {
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

  PathW dirPath;

  _FolderPaneItem({
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
