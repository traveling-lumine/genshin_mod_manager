import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/service/preset_service.dart';
import 'package:genshin_mod_manager/window/home.dart';
import 'package:genshin_mod_manager/window/page/category.dart';
import 'package:genshin_mod_manager/window/page/license.dart';
import 'package:genshin_mod_manager/window/page/setting.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const resourceDir = PathW('Resources');
  static final Logger logger = Logger();

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
          return _buildMain(context);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        if (snapshot.hasError) {
          logger.e('App FutureBuilder snapshot error: ${snapshot.error}');
          return _buildError(context, snapshot.error);
        }
        return _buildMain(context);
      },
    );
  }

  Widget _buildError(BuildContext context, Object? error) {
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

  Widget _buildLoading() {
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

  Widget _buildMain(BuildContext context) {
    final modResourcePath = PathW(Platform.resolvedExecutable)
        .dirname
        .join(resourceDir)
      ..toDirectory.createSync();
    return Selector<AppStateService, PathW>(
      selector: (p0, p1) => p1.modRoot,
      builder: (BuildContext context, PathW modRootValue, Widget? child) {
        return MultiProvider(
          key: Key(modRootValue.asString),
          providers: [
            ChangeNotifierProvider(
              create: (context) => CategoryIconFolderObserverService(
                  targetDir: modResourcePath.toDirectory),
            ),
            ChangeNotifierProvider(
              create: (context) =>
                  RecursiveObserverService(targetDir: modRootValue.toDirectory),
            ),
          ],
          child: _buildHomeWindowScope(modRootValue),
        );
      },
    );
  }

  Widget _buildHomeWindowScope(PathW modRootValue) {
    return ChangeNotifierProxyProvider2<AppStateService,
        RecursiveObserverService, PresetService>(
      create: (context) => PresetService(),
      update: (context, value, value2, previous) =>
          previous!..update(value, value2),
      child: DirWatchProvider(
        dir: modRootValue.toDirectory,
        child: FluentApp.router(
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
        ),
      ),
    );
  }

  final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SettingPage(),
          ),
          GoRoute(
            path: '/setting',
            builder: (context, state) => const SettingPage(),
          ),
          GoRoute(
            path: '/license',
            builder: (context, state) => const OssLicensesPage(),
          ),
          GoRoute(
            path: '/category/:name',
            redirect: (context, state) {
              print('Redirecting to /setting');
              final categories = context
                  .read<DirWatchService>()
                  .curDirs
                  .map((e) => e.pathW.basename.asString)
                  .toList(growable: false);
              final currentName = state.pathParameters['name']!;
              if (!categories.contains(currentName)) {
                return '/setting';
              }
            },
            builder: (context, state) {
              final category = state.pathParameters['name']!;
              final modRoot = context.read<AppStateService>().modRoot;
              final dir = modRoot.join(category.pathW).toDirectory;
              return DirWatchProvider(
                key: Key(category),
                dir: dir,
                child: CategoryPage(category: category),
              );
            },
          ),
        ],
      ),
    ],
  );
}
