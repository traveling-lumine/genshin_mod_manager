import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/route_refresh_service.dart';
import 'package:genshin_mod_manager/route/home_shell.dart';
import 'package:genshin_mod_manager/route/loading.dart';
import 'package:genshin_mod_manager/route/category.dart';
import 'package:genshin_mod_manager/route/license.dart';
import 'package:genshin_mod_manager/route/setting.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const _minWindowSize = Size(600, 600);

void main() async {
  await _initialize();
  _registerErrorHandlers();
  runApp(_MyApp());
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: _minWindowSize,
  ));
}

void _registerErrorHandlers() {
  FlutterError.onError = (details) {
    final now = DateTime.now().toUtc().toIso8601String();
    final message = _errorToString(details);
    String stackTrace = _writeStacktrace(details);
    try {
      File('error.log').writeAsStringSync(
        '[$now]\nMessage:\n$message\nStacktrace:\n$stackTrace\n\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // print('Error writing to error log: $e');
    }
  };

  ErrorWidget.builder = (details) {
    return Center(
      child: SelectableText(
        _errorToString(details),
        style: TextStyle(color: Colors.red.darker),
      ),
    );
  };
}

String _writeStacktrace(FlutterErrorDetails details) {
  try {
    final stackTrace = details.stack.toString();
    return _elideLines(stackTrace);
  } catch (e) {
    return 'Stack trace not available';
  }
}

String _elideLines(String stackTrace) {
  // only choose lines that include genshin_mod_manager. Lines that don't include it are shrunk to ...
  final lines = [];
  int elidedLines = 0;
  for (final line in stackTrace.split('\n')) {
    if (line.contains('genshin_mod_manager')) {
      if (elidedLines > 0) {
        lines.add('... ($elidedLines lines elided)');
        elidedLines = 0;
      }
      lines.add(line);
      elidedLines = 0;
    } else {
      elidedLines++;
    }
  }
  if (elidedLines > 0) {
    lines.add('... ($elidedLines lines elided)');
  }
  return lines.join('\n');
}

String _errorToString(FlutterErrorDetails details) {
  try {
    return details.exception.toString();
  } catch (e) {
    try {
      return details.toString();
    } catch (e) {
      return 'An error occurred';
    }
  }
}

final kNavigationKey = GlobalKey<NavigatorState>();

class _MyApp extends StatelessWidget {
  final _routeRefreshService = RouteRefreshService();
  late final _router = GoRouter(
    navigatorKey: kNavigationKey,
    debugLogDiagnostics: true,
    initialLocation: '/loading',
    refreshListenable: _routeRefreshService,
    redirect: (context, state) {
      final read = context.read<RouteRefreshService>();
      final destination2 = read.destination;
      read.clear();
      return destination2;
    },  
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingRoute(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/setting',
            builder: (context, state) => const SettingRoute(),
          ),
          GoRoute(
            path: '/license',
            builder: (context, state) => const OssLicensesRoute(),
          ),
          GoRoute(
            path: '/category/:name',
            builder: (context, state) => CategoryRoute(
              category: state.pathParameters['name']!,
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _routeRefreshService),
        ChangeNotifierProxyProvider<RouteRefreshService, AppStateService>(
          create: (context) => AppStateService(),
          update: (context, value, previous) => previous!..update(value),
        ),
      ],
      child: FluentApp.router(
        title: 'Genshin Mod Manager',
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,
      ),
    );
  }
}
