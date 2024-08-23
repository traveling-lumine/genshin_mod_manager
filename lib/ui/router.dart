import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../backend/structure/entity/mod_category.dart';
import '../backend/storage/di/app_state.dart';
import 'constant.dart';
import 'route/category/category.dart';
import 'route/home_shell.dart';
import 'route/license.dart';
import 'route/loading.dart';
import 'route/nahida_store/nahida_store.dart';
import 'route/setting.dart';
import 'route/welcome.dart';

/// The main application widget.
class MyApp extends ConsumerStatefulWidget {
  /// Creates a [MyApp].
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _router = GoRouter(
    debugLogDiagnostics: true,
    extraCodec: const ModCategoryCodec(),
    initialLocation: kLoadingRoute,
    routes: [
      GoRoute(
        path: kLoadingRoute,
        builder: (final context, final state) => const LoadingRoute(),
      ),
      ShellRoute(
        builder: (final context, final state, final child) =>
            HomeShell(child: child),
        routes: [
          GoRoute(
            path: kHomeRoute,
            builder: (final context, final state) => const WelcomeRoute(),
          ),
          GoRoute(
            path: kSettingRoute,
            builder: (final context, final state) => const SettingRoute(),
          ),
          GoRoute(
            path: kLicenseRoute,
            builder: (final context, final state) => const OssLicensesRoute(),
          ),
          GoRoute(
            path: kCategoryRoute,
            builder: (final context, final state) =>
                CategoryRoute(category: state.extra! as ModCategory),
          ),
          GoRoute(
            path: kNahidaStoreRoute,
            builder: (final context, final state) =>
                NahidaStoreRoute(category: state.extra! as ModCategory),
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
      darkTheme: FluentThemeData.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      title: 'Genshin Mod Manager',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
