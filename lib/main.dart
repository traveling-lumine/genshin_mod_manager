import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/state.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'fsops.dart';
import 'page/folder.dart';
import 'page/setting.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(600, 600));
  });

  final instance = await SharedPreferences.getInstance();
  final String targetDir = instance.getString('targetDir') ?? '.';
  final String launcherDir = instance.getString('launcherDir') ?? '.';

  runApp(MyApp(targetDir, launcherDir));
}

class MyApp extends StatelessWidget {
  final String targetDir;
  final String launcherDir;

  const MyApp(this.targetDir, this.launcherDir, {super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Genshin Mod Manager',
      home: ChangeNotifierProvider(
        create: (BuildContext context) => AppState(targetDir, launcherDir),
        builder: (context, child) {
          return const MyHomePage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  String? targetDir;
  late Directory watchDir;

  StreamSubscription<FileSystemEvent>? watcher;
  late List<NavigationPaneItem> subFolders;
  int? selected;

  void updateFolder(String tDir) {
    targetDir = tDir;
    watchDir = Directory(targetDir!);
    watcher?.cancel();
    subFolders = [];
    selected = null;

    getAllChildrenFolder(targetDir!).forEach((element) {
      subFolders.add(FolderPaneItem(folder: element));
    });
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
    return Consumer<AppState>(
      builder: (BuildContext context, AppState value, Widget? child) {
        var targetDir2 = '${value.targetDir}\\Mods';
        if (targetDir == null) {
          targetDir = targetDir2;
          updateFolder(targetDir!);
        } else if (targetDir != targetDir2) {
          updateFolder(targetDir2);
        }
        return NavigationView(
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          appBar: const NavigationAppBar(
            title: DragToMoveArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Genshin Mod Manager'),
              ),
            ),
            automaticallyImplyLeading: false,
            actions: WindowButtons(),
          ),
          pane: NavigationPane(
            selected: selected,
            onChanged: (i) => setState(() => selected = i),
            displayMode: PaneDisplayMode.auto,
            size: const NavigationPaneSize(openWidth: 250),
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
                  selected = subFolders
                      .indexWhere((element) => element.key == item.value);
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
          ),
        );
      },
    );
  }
}

class ExecPaneItem extends PaneItem {
  String program;

  ExecPaneItem({
    required super.icon,
    required this.program,
  }) : super(
          title: Text(program.split('\\').last.split('.').first),
          body: Text(program),
          onTap: () {
            runProgram(program);
          },
        );
}

class FolderPaneItem extends PaneItem {
  String folder;

  FolderPaneItem({
    required this.folder,
  }) : super(
          title: Text(folder.split('\\').last),
          icon: const Icon(FluentIcons.folder_open),
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
