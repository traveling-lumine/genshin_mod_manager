import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

import 'src/di/app_state/dark_mode.dart';
import 'src/di/exe_arg.dart';
import 'src/error_handler.dart';
import 'src/ui/route/category.dart';
import 'src/ui/route/first_page.dart';
import 'src/ui/route/home_shell.dart';
import 'src/ui/route/license.dart';
import 'src/ui/route/loading.dart';
import 'src/ui/route/nahida_store.dart';
import 'src/ui/route/setting.dart';
import 'src/ui/route/welcome.dart';
import 'src/ui/route_names.dart';

void main(final List<String> args) async {
  await _initialize();
  if (!kDebugMode) {
    registerErrorHandlers();
  }
  ArgProvider.initial = args;
  runApp(const ProviderScope(child: _MyApp()));
}

const _kMinWindowSize = Size(800, 600);

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await protocolHandler.register('gmm-interop-uri');
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      minimumSize: _kMinWindowSize,
    ),
  );
}

class _MyApp extends ConsumerStatefulWidget {
  const _MyApp();

  @override
  ConsumerState<_MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<_MyApp> {
  final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.loading.name,
    routes: [
      GoRoute(
        path: RouteNames.loading.name,
        builder: (final context, final state) => const LoadingRoute(),
      ),
      GoRoute(
        path: RouteNames.firstpage.name,
        builder: (final context, final state) => const FirstRoute(),
      ),
      ShellRoute(
        builder: (final context, final state, final child) =>
            HomeShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home.name,
            builder: (final context, final state) => const WelcomeRoute(),
          ),
          GoRoute(
            path: RouteNames.setting.name,
            builder: (final context, final state) => const SettingRoute(),
          ),
          GoRoute(
            path: RouteNames.license.name,
            builder: (final context, final state) => const OssLicensesRoute(),
          ),
          GoRoute(
            path: '${RouteNames.category.name}/:category',
            builder: (final context, final state) {
              final categoryName = state.pathParameters['category']!;
              return CategoryRoute(categoryName: categoryName);
            },
          ),
          GoRoute(
            path: '${RouteNames.nahidastore.name}/:category',
            builder: (final context, final state) {
              final categoryName = state.pathParameters['category']!;
              return NahidaStoreRoute(categoryName: categoryName);
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    return FluentApp.router(
      theme: FluentThemeData.light(),
      darkTheme: FluentThemeData.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      title: 'Genshin Mod Manager',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }
}
