import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/route/category.dart';
import 'package:genshin_mod_manager/route/home_shell.dart';
import 'package:genshin_mod_manager/route/license.dart';
import 'package:genshin_mod_manager/route/loading.dart';
import 'package:genshin_mod_manager/route/nahida_store.dart';
import 'package:genshin_mod_manager/route/setting.dart';
import 'package:genshin_mod_manager/route/welcome.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
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

class _MyApp extends StatelessWidget {
  late final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/loading',
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingRoute(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const WelcomeRoute(),
          ),
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
          GoRoute(
            path: '/nahidastore',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return NahidaStoreRoute(category: category!);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateService(),
      child: FluentApp.router(
        title: 'Genshin Mod Manager',
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,
      ),
    );
  }
}
