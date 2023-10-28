import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/window/home.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const _minWindowSize = Size(600, 600);

void main() async {
  await initialize();
  runApp(const MyApp());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setMinimumSize(_minWindowSize);
  });
}

class MyApp extends StatelessWidget {
  static const resourceDir = PathString('Resources');
  static const modDir = PathString('Mods');
  static const sharedPreferencesAwaitTime = Duration(seconds: 5);
  static final Logger logger = Logger();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Genshin Mod Manager',
      home: FutureBuilder(
        future: getAppState().timeout(
          sharedPreferencesAwaitTime,
          onTimeout: () {
            logger.e('Unable to obtain SharedPreference settings');
            return AppState.defaultState();
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
        final dirPath = context.select<AppState, PathString>(
            (value) => value.targetDir.join(modDir));
        final curExePath = PathString(Platform.resolvedExecutable);
        final curExeParentDir = curExePath.dirname;
        final modResourcePath = curExeParentDir.join(resourceDir);
        modResourcePath.toDirectory.createSync();
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
