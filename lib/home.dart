import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app_state.dart';
import 'fsops.dart';
import 'page/folder.dart';
import 'page/setting.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  late Directory watchDir;
  late List<NavigationPaneItem> subFolders;
  StreamSubscription<FileSystemEvent>? watcher;
  String? targetDir;
  int? selected;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    watcher?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var targetDir2 =
        '${context.select<AppState, String>((value) => value.targetDir)}\\Mods';
    if (targetDir == null) {
      targetDir = targetDir2;
      updateFolder(targetDir!);
    } else if (targetDir != targetDir2) {
      updateFolder(targetDir2);
    }
    return NavigationView(
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      appBar: buildNavigationAppBar(),
      pane: buildNavigationPane(context),
    );
  }

  NavigationPane buildNavigationPane(BuildContext context) {
    return NavigationPane(
      selected: selected,
      onChanged: (i) => setState(() => selected = i),
      displayMode: PaneDisplayMode.auto,
      size: const NavigationPaneSize(openWidth: 300),
      autoSuggestBox: AutoSuggestBox(
        items: subFolders
            .map((e) => AutoSuggestBoxItem(
                  value: e.key,
                  label: (e as FolderPaneItem).folder.split('\\').last,
                ))
            .toList(),
        trailingIcon: const Icon(FluentIcons.search),
        onSelected: (item) {
          setState(() {
            selected =
                subFolders.indexWhere((element) => element.key == item.value);
          });
        },
      ),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
      items: subFolders,
      footerItems: [
        PaneItemSeparator(),
        PaneItem(
          icon: const Icon(FluentIcons.user_window),
          title: const Text('3d migoto'),
          body: Center(child: Image.asset('images/app_icon.ico')),
          onTap: () {
            final path =
                '${context.read<AppState>().targetDir}\\3DMigoto Loader.exe';
            runProgram(path);
            print('run!');
          },
        ),
        PaneItem(
          icon: const Icon(FluentIcons.user_window),
          title: const Text('Launcher'),
          body: Center(child: Image.asset('images/app_icon.ico')),
          onTap: () {
            runProgram(context.read<AppState>().launcherDir);
          },
        ),
        PaneItem(
          icon: const Icon(FluentIcons.settings),
          title: const Text('Settings'),
          body: const SettingPage(),
        ),
      ],
    );
  }

  NavigationAppBar buildNavigationAppBar() {
    return const NavigationAppBar(
      title: DragToMoveArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Genshin Mod Manager'),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: WindowButtons(),
    );
  }

  void updateFolder(String tDir) {
    targetDir = tDir;
    watchDir = Directory(targetDir!);
    watcher?.cancel();
    subFolders = [];
    selected = null;

    try {
      getAllChildrenFolder(targetDir!).forEach((element) {
        subFolders.add(FolderPaneItem(folder: element));
      });
    } on PathNotFoundException {
      print('Path not found: $targetDir');
    }
    watcher = watchDir.watch().listen((event) {
      setState(() {
        final NavigationPaneItem? prevSelItem;
        if (selected != null) {
          prevSelItem = subFolders[selected!];
        } else {
          prevSelItem = null;
        }
        subFolders = [];
        getAllChildrenFolder(targetDir!).forEach((element) {
          subFolders.add(FolderPaneItem(folder: element));
        });
        if (prevSelItem != null) {
          // find the index of prevSelItem using key
          final index = subFolders.indexWhere((element) {
            return element.key == prevSelItem!.key;
          });
          if (index != -1) {
            selected = index;
          }
        }
      });
    });
  }
}

class FolderPaneItem extends PaneItem {
  String folder;

  FolderPaneItem({
    required this.folder,
  }) : super(
          title: Text(folder.split('\\').last),
          icon: Image.asset('images/app_icon.ico'),
          body: FolderPage(folder: folder),
          key: ValueKey(folder),
        );
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
