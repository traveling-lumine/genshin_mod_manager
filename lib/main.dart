import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'provider/app_state.dart';
import 'window/home.dart';

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
          const Duration(seconds: 5),
          onTimeout: () {
            logger.e('Unable to obtain SharedPreference settings');
            return AppState('.', '.', false, false, true);
          },
        ),
        builder: (context, snapshot) {
          logger.d('App FutureBuilder snapshot status: $snapshot');
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
        final dirPath = context.select<AppState, String>(
            (value) => p.join(value.targetDir, 'Mods'));
        final curExePath = Platform.resolvedExecutable;
        final curExeParentDir = p.dirname(curExePath);
        final modResourcePath = p.join(curExeParentDir, 'Resources');
        Directory(modResourcePath).createSync();
        return HomeWindow(dirPaths: [dirPath, modResourcePath]);
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
}
