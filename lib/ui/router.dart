import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/route/category/category.dart';
import 'package:genshin_mod_manager/ui/route/home_shell/home_shell.dart';
import 'package:genshin_mod_manager/ui/route/license.dart';
import 'package:genshin_mod_manager/ui/route/loading.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store/nahida_store.dart';
import 'package:genshin_mod_manager/ui/route/setting/setting.dart';
import 'package:genshin_mod_manager/ui/route/welcome.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  late final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: kLoadingRoute,
    extraCodec: const ModCategoryCodec(),
    routes: [
      GoRoute(
        path: kLoadingRoute,
        builder: (context, state) => const LoadingRoute(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: kHomeRoute,
            builder: (context, state) => const WelcomeRoute(),
          ),
          GoRoute(
            path: kSettingRoute,
            builder: (context, state) => const SettingRoute(),
          ),
          GoRoute(
            path: kLicenseRoute,
            builder: (context, state) => const OssLicensesRoute(),
          ),
          GoRoute(
            path: kCategoryRoute,
            builder: (context, state) =>
                CategoryRoute(category: state.extra as ModCategory),
          ),
          GoRoute(
            path: kNahidaStoreRoute,
            builder: (context, state) =>
                NahidaStoreRoute(category: state.extra as ModCategory),
          ),
        ],
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => createAppStateService(),
      child: FluentApp.router(
        title: 'Genshin Mod Manager',
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        routeInformationProvider: _router.routeInformationProvider,
      ),
    );
  }
}
