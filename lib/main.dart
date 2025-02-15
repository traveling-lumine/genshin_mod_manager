import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app_config/l1/di/exe_arg.dart';
import 'src/error_handler/error_handler.dart';
import 'src/ui/../app_config/l0/entity/entries.dart';
import 'src/ui/../app_config/l1/di/app_config_facade.dart';
import 'src/ui/../l10n/app_localizations.dart';
import 'src/ui/constants.dart';
import 'src/ui/route/category.dart';
import 'src/ui/route/first_page.dart';
import 'src/ui/route/hero_page.dart';
import 'src/ui/route/home_shell.dart';
import 'src/ui/route/license.dart';
import 'src/ui/route/loading.dart';
import 'src/ui/route/nahida_store.dart';
import 'src/ui/route/setting.dart';
import 'src/ui/route/welcome.dart';
import 'src/ui/widget/category_provider_widget.dart';
import 'src/ui/widget/empty_game_redirector.dart';
import 'src/ui/widget/game_redirector.dart';

void main(final List<String> args) async {
  await _initialize();
  if (!kDebugMode) {
    registerErrorHandlers();
  }
  ArgProvider.initial = args;
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await protocolHandler.register(protocol);
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      minimumSize: Size(800, 600),
    ),
  );
}

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
        builder: (final context, final state) =>
            const GameRedirector(child: FirstRoute()),
      ),
      ShellRoute(
        builder: (final context, final state, final child) =>
            EmptyGameRedirector(child: HomeShell(child: child)),
        routes: [
          GoRoute(
            name: RouteNames.home.name,
            path: '/',
            builder: (final context, final state) => const WelcomeRoute(),
            routes: [
              GoRoute(
                name: RouteNames.categoryHero.name,
                path: '/categoryHero/:${RouteParams.categoryHeroTag.name}',
                pageBuilder: (final context, final state) {
                  final heroTag =
                      state.pathParameters[RouteParams.categoryHeroTag.name]!;
                  return heroPage(context, heroTag);
                },
              ),
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
                  return CategoryProviderWidget(
                    builder: (final category) => CategoryRoute(
                      category: category,
                      key: ValueKey(categoryName),
                    ),
                    categoryName: categoryName,
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
    final darkMode1 = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(darkMode)),
    );
    return FluentApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale.fromSubtags(languageCode: 'en'),
      theme: FluentThemeData.light(),
      darkTheme: FluentThemeData.dark(),
      themeMode: darkMode1 ? ThemeMode.dark : ThemeMode.light,
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
