import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/window/home.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  static const resourceDir = PathString('Resources');
  static const modDir = PathString('Mods');
  static const sharedPreferencesAwaitTime = Duration(seconds: 5);
  static final Logger logger = Logger();

  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool overrideBuild = false;

  @override
  Widget build(BuildContext context) {
    final initFuture =
        context.select<AppStateService, Future<SharedPreferences>>(
            (value) => value.initFuture);
    return FutureBuilder(
      future: initFuture,
      builder: (context, snapshot) {
        if (overrideBuild) {
          return buildMain(context);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoadingScreen();
        }
        if (snapshot.hasError) {
          LoadingScreen.logger
              .e('App FutureBuilder snapshot error: ${snapshot.error}');
          return buildErrorScreen(context, snapshot.error);
        }
        return buildMain(context);
      },
    );
  }

  Widget buildErrorScreen(BuildContext context, Object? error) {
    return NavigationView(
      appBar: getAppbar("Error!"),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  onPressed: () => context.read<AppStateService>().init(),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                Button(
                  onPressed: () => setState(() => overrideBuild = true),
                  child: const Text('Override'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadingScreen() {
    return NavigationView(
      appBar: getAppbar("Loading..."),
      content: const Center(
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

  Widget buildMain(BuildContext context) {
    final dirPath = context.select<AppStateService, PathString>(
        (value) => value.targetDir.join(LoadingScreen.modDir));
    final curExePath = PathString(Platform.resolvedExecutable);
    final curExeParentDir = curExePath.dirname;
    final modResourcePath = curExeParentDir.join(LoadingScreen.resourceDir);
    modResourcePath.toDirectory.createSync();
    return HomeWindow(dirPaths: [dirPath, modResourcePath]);
  }
}
