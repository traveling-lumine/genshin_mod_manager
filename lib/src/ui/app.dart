import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_state/dark_mode.dart';
import 'constants.dart';
import 'route/category.dart';
import 'route/first_page.dart';
import 'route/hero_page.dart';
import 'route/home_shell.dart';
import 'route/license.dart';
import 'route/loading.dart';
import 'route/nahida_store.dart';
import 'route/setting.dart';
import 'route/welcome.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/loading',
    routes: [
      GoRoute(
        name: RouteNames.loading.name,
        path: '/loading',
        builder: (final context, final state) => const LoadingRoute(),
      ),
      GoRoute(
        name: RouteNames.firstpage.name,
        path: '/firstpage',
        builder: (final context, final state) => const FirstRoute(),
      ),
      GoRoute(
        name: RouteNames.categoryHero.name,
        path: '/categoryHero/:${RouteParams.categoryHeroTag.name}',
        pageBuilder: (final context, final state) {
          final heroTag =
              state.pathParameters[RouteParams.categoryHeroTag.name]!;
          return heroPage(context, heroTag);
        },
      ),
      ShellRoute(
        builder: (final context, final state, final child) =>
            HomeShell(child: child),
        routes: [
          GoRoute(
            name: RouteNames.home.name,
            path: '/',
            builder: (final context, final state) => const WelcomeRoute(),
            routes: [
              GoRoute(
                name: RouteNames.setting.name,
                path: 'setting',
                builder: (final context, final state) => const SettingRoute(),
                routes: [
                  GoRoute(
                    name: RouteNames.license.name,
                    path: 'license',
                    builder: (final context, final state) =>
                        const OssLicensesRoute(),
                  ),
                ],
              ),
              GoRoute(
                name: RouteNames.category.name,
                path: 'category/:${RouteParams.category.name}',
                builder: (final context, final state) {
                  final categoryName =
                      state.pathParameters[RouteParams.category.name]!;
                  return CategoryRoute(
                    categoryName: categoryName,
                    key: ValueKey(categoryName),
                  );
                },
              ),
              GoRoute(
                name: RouteNames.nahidaStore.name,
                path: 'nahidaStore/:${RouteParams.category.name}',
                builder: (final context, final state) {
                  final categoryName =
                      state.pathParameters[RouteParams.category.name]!;
                  return NahidaStoreRoute(categoryName: categoryName);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(final BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    return FluentApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale.fromSubtags(languageCode: 'en'),
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
