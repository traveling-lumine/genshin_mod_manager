import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/window/home.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await initialize();
  runApp(const MyApp());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(const Size(600, 600));
  });
}

class MyApp extends StatelessWidget {
  static final Logger logger = Logger();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Genshin Mod Manager',
      home: FutureBuilder(
        future: getAppState().timeout(
          const Duration(seconds: 1),
          onTimeout: () => AppState('.', '.'),
        ),
        builder: (context, snapshot) {
          logger.i('App FutureBuilder snapshot status: $snapshot');
          if (!snapshot.hasData) {
            return buildLoadingScreen();
          }
          return buildMain(snapshot.data!);
        },
      ),
    );
  }

  Widget buildMain(AppState data) {
    return ChangeNotifierProvider.value(
      value: data,
      builder: (context, child) {
        final dir = context.select<AppState, Directory>(
            (value) => Directory(p.join(value.targetDir, "Mods")));
        return HomeWindow(dir);
      },
    );
  }

  Widget buildLoadingScreen() {
    return const ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressRing(),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Future<AppState> getAppState() async {
    final instance = await SharedPreferences.getInstance();
    final String targetDir = instance.getString('targetDir') ?? '.';
    final String launcherFile = instance.getString('launcherDir') ?? '.';
    final appState = AppState(targetDir, launcherFile);
    return appState;
  }
}
