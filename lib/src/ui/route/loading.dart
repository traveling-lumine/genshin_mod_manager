import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_config/l0/entity/app_config.dart';
import '../../app_config/l1/impl/app_config_facade.dart';
import '../../app_config/l1/impl/app_config_persistent_repo.dart';
import '../../error_handler/error_handler.dart';
import '../../legacy_storage/shared_storage.dart';
import '../../legacy_storage/sharedpreference_storage.dart';
import '../constants.dart';
import '../widget/appbar.dart';

class LoadingRoute extends ConsumerStatefulWidget {
  const LoadingRoute({super.key});

  @override
  ConsumerState<LoadingRoute> createState() => _LoadingRouteState();
}

class _LoadingRouteState extends ConsumerState<LoadingRoute> {
  late Future<void> _migrationFuture = _migrate();

  @override
  Widget build(final BuildContext context) {
    ref.listen(appConfigFacadeProvider, (final previous, final next) {
      context.goNamed(
        next.obtainValue(games).gameConfig.isEmpty
            ? RouteNames.firstpage.name
            : RouteNames.home.name,
      );
    });
    return NavigationView(
      appBar: getAppbar('Loading...'),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProgressRing(),
            const SizedBox(height: 16),
            _buildConfigMigrationFuture(),
          ],
        ),
      ),
    );
  }

  FutureBuilder<void> _buildConfigMigrationFuture() => FutureBuilder(
        key: ValueKey(_migrationFuture),
        future: _migrationFuture,
        builder: (final context, final snapshot) {
          if (snapshot.hasError) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Migration failed: ${snapshot.error}\n'
                    '${elideLines(snapshot.stackTrace.toString())}'),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: () => setState(() {
                    unawaited(_migrationFuture = _migrate());
                  }),
                  child: const Text('Retry'),
                ),
              ],
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return const Text('Migration done');
          }
          return const Text('Migrating configuration...');
        },
      );

  Future<void> _migrate() async {
    final instance = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 5));
    final config = await migrateUseCase(
      facade: const AppConfigFacadeImpl(currentConfig: AppConfig({})),
      storage: SharedPreferenceStorage(instance),
      repository: ref.read(appConfigPersistentRepoProvider),
    );
    if (config != null) {
      ref.read(appConfigCProvider.notifier).update(config);
    } else {
      if (!AppConfigPersistentRepoImpl.settingsFile.existsSync()) {
        await AppConfigPersistentRepoImpl.settingsFile.writeAsString('{}');
      }
    }
  }
}
