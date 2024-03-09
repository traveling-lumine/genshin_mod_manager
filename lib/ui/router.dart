import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/ui/route/category/category.dart';
import 'package:genshin_mod_manager/ui/route/home_shell.dart';
import 'package:genshin_mod_manager/ui/route/license.dart';
import 'package:genshin_mod_manager/ui/route/loading.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store.dart';
import 'package:genshin_mod_manager/ui/route/setting.dart';
import 'package:genshin_mod_manager/ui/route/welcome.dart';
import 'package:genshin_mod_manager/ui/service/app_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
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
            builder: (context, state) {
              final category = state.pathParameters['name']!;
              return CategoryRoute(category: category);
            },
            redirect: (context, state) {
              final pathParameter = state.pathParameters['name'];
              return pathParameter == null ? '/' : null;
            },
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

  MyApp({super.key});

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
