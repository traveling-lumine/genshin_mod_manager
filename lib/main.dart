import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(600, 600));
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  static String targetDir = r'C:\Users\hello\Genshin Skin\3dmigoto\Mods\SkinSelectImpact';
  final Directory watcher = Directory(targetDir);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NavigationPaneItem> a = [];

  @override
  void initState() {
    getAllChildrenFolder(MyHomePage.targetDir).forEach((element) {
      a.add(FolderPaneItem(folder: element));
      print(element);
    });
    widget.watcher.watch().listen((event) {
      setState(() {
        getAllChildrenFolder(MyHomePage.targetDir).forEach((element) {
          a = [];
          a.add(FolderPaneItem(folder: element));
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: DragToMoveArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Genshin Mod Manager'),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: WindowCaption(),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.open,
        size: const NavigationPaneSize(openWidth: 200),
        items: a,
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.a_a_d_logo),
            body: const SizedBox.shrink(),
            onTap: () {
              setState(() {
                a.add(FolderPaneItem(folder: 'C:\\Windows\\System32'));
              });
            },
          ),
          ExecPaneItem(
            program: 'C:\\Windows\\System32\\mspaint.exe',
            icon: const Icon(FluentIcons.user_window),
          ),
          ExecPaneItem(
            program: 'C:\\Windows\\System32\\notepad.exe',
            icon: const Icon(FluentIcons.settings),
          ),
        ],
      ),
      paneBodyBuilder: (item, body) {
        return const Center(
          child: ProgressRing(),
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
          body: const SizedBox.shrink(),
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
          body: const SizedBox.shrink(),
          onTap: () {
            openFolder(folder);
          },
        );
}

void runProgram(String program) {
  Process.start(
    'start',
    [program],
    runInShell: true,
  );
}

void openFolder(String dir) {
  Process.start(
    'explorer',
    [dir],
    runInShell: true,
  );
}

List<String> getAllChildrenFolder(String dir) {
  List<String> a = [];
  Directory(dir).listSync().forEach((element) {
    if (element is Directory) {
      a.add(element.path);
    }
  });
  return a;
}