import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'di/app_state.dart';
import 'route/category/category.dart';
import 'route/home_shell.dart';
import 'route/license.dart';
import 'route/loading.dart';
import 'route/nahida_store/nahida_store.dart';
import 'route/setting.dart';
import 'route/welcome.dart';
import 'route_names.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.loading.name,
    routes: [
      GoRoute(
        path: RouteNames.loading.name,
        builder: (final context, final state) => const LoadingRoute(),
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
  void dispose() {
    _router.dispose();
    super.dispose();
  }

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
}
