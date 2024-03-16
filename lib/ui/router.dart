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
  MyApp({super.key});

  final _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: kLoadingRoute,
    extraCodec: const ModCategoryCodec(),
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
  Widget build(final BuildContext context) => Provider(
        create: (final context) => createAppStateService(),
        dispose: (final context, final value) => value.dispose(),
        child: FluentApp.router(
          title: 'Genshin Mod Manager',
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
        ),
      );
}
