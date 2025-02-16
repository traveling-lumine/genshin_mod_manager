import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_config/l0/api/app_config_facade.dart';
import '../../app_config/l0/entity/app_config.dart';
import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
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
      unawaited(_createIconFolders(next));
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
            _buildConfigStatus(),
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
                Expanded(
                  child: Text('Setting migration: failed: ${snapshot.error}\n'
                      '${elideLines(snapshot.stackTrace.toString())}'),
                ),
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
            return const Text('Setting migration: done...');
          }
          return const Text('Setting migration: in progress...');
        },
      );

  Widget _buildConfigStatus() => ref.watch(appConfigCProvider).when(
        data: (final config) => const Text('Configuration loading: done'),
        loading: () => const Text('Configuration loading: in progress...'),
        error: (final error, final stackTrace) =>
            Text('Configuration loading: failed: $error'),
      );

  Future<void> _copyGameIcons(
    final String name,
    final String? modRoot,
    final List<File> rawIcons,
  ) async {
    if (modRoot == null) {
      return;
    }
    final modRootDir = Directory(modRoot);
    if (!modRootDir.existsSync()) {
      return;
    }
    final iconDirGame = Directory(
      p.join(
        File(Platform.resolvedExecutable).parent.path,
        'Resources',
        name,
      ),
    );
    if (!iconDirGame.existsSync()) {
      return;
    }
    final modRootSubDirs = await modRootDir
        .list()
        .whereType<Directory>()
        .map(
          (final event) => p.basename(event.path).toLowerCase(),
        )
        .toList();

    final commonFiles = rawIcons
        .where(
          (final e) => modRootSubDirs
              .contains(p.basenameWithoutExtension(e.path).toLowerCase()),
        )
        .toList();

    await Future.wait(
      commonFiles.map<Future<void>>(
        (final e) async {
          final join = p.join(iconDirGame.path, p.basename(e.path));
          if (File(join).existsSync()) {
            return;
          }
          await e.copy(join);
        },
      ),
    );
  }

  Future<void> _createIconFolders(final AppConfigFacade facade) async {
    await Directory(
      p.join(File(Platform.resolvedExecutable).parent.path, 'Resources'),
    ).create(recursive: true);
    final gameList = facade.obtainValue(games).gameConfig;
    final gameDirCreateFuture = Future.wait(
      gameList.keys
          .toList()
          .map(
            (final e) => Directory(
              p.join(
                File(Platform.resolvedExecutable).parent.path,
                'Resources',
                e,
              ),
            ),
          )
          .whereNot((final e) => e.existsSync())
          .map((final e) => e.create(recursive: true)),
    );
    final listFiles = await Directory(
      p.join(File(Platform.resolvedExecutable).parent.path, 'Resources'),
    ).list().whereType<File>().toList();
    try {
      await gameDirCreateFuture;
    } on FileSystemException {
      // do nothing. the rest of the code will continue
    }
    if (listFiles.isEmpty) {
      return;
    }
    await Future.wait(
      gameList.entries.map(
        (final e) => _copyGameIcons(
          e.key,
          e.value.modRoot,
          listFiles,
        ),
      ),
    );
  }

  Future<void> _migrate() async {
    final instance = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 5));
    final config = await migrateUseCase(
      facade: const AppConfigFacadeImpl(currentConfig: AppConfig({})),
      storage: SharedPreferenceStorage(instance),
      repository: ref.read(appConfigPersistentRepoProvider),
    );
    if (config != null) {
      ref.read(appConfigCProvider.notifier).setData(config);
    } else {
      if (!AppConfigPersistentRepoImpl.settingsFile.existsSync()) {
        await AppConfigPersistentRepoImpl.settingsFile.writeAsString('{}');
      }
    }
  }
}
