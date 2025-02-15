import 'dart:ui';

import '../app_config/l0/api/app_config_facade.dart';
import '../app_config/l0/api/app_config_persistent_repo.dart';
import '../app_config/l0/entity/app_config.dart';
import '../app_config/l0/entity/column_strategy.dart';
import '../app_config/l0/entity/entries.dart';
import '../app_config/l0/entity/game_config.dart';
import '../app_config/l0/entity/preset.dart';
import '../filesystem/l1/impl/path_op_string.dart';
import 'sharedpreference_storage.dart';

final configVersionKey = StorageAccessKey.configVersion.name;

enum StorageAccessKey {
  cardColorBrightEnabled,
  cardColorBrightDisabled,
  cardColorDarkEnabled,
  cardColorDarkDisabled,

  runTogether,

  moveOnDrag,

  iniEditorArg,

  showFolderIcon,

  showEnabledModsFirst,

  darkMode,

  showPaimonAsEmptyIconFolderIcon,

  separateRunSuffix('.overrideRun'),

  windowWidth,
  windowHeight,

  columnStrategyType,
  columnStrategyValue,

  configVersion;

  const StorageAccessKey([this.overrideValue]);
  final String? overrideValue;

  String get name => overrideValue ?? (this as Enum).name;
}

Future<AppConfig?> migrateUseCase({
  required final AppConfigFacade facade,
  required final SharedPreferenceStorage storage,
  required final AppConfigPersistentRepo repository,
}) async {
  afterInitializationUseCase(storage);
  if (storage.getInt('didMigration') == 1) {
    return null;
  }

  var config = const AppConfig({});

  final ccb = storage.getInt(StorageAccessKey.cardColorBrightEnabled.name);
  if (ccb != null) {
    final config2 = facade.storeValue(cardColorBrightEnabled, Color(ccb));
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final ccd = storage.getInt(StorageAccessKey.cardColorBrightDisabled.name);
  if (ccd != null) {
    final config2 = facade.storeValue(cardColorBrightDisabled, Color(ccd));
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final ccdk = storage.getInt(StorageAccessKey.cardColorDarkEnabled.name);
  if (ccdk != null) {
    final config2 = facade.storeValue(cardColorDarkEnabled, Color(ccdk));
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final ccdd = storage.getInt(StorageAccessKey.cardColorDarkDisabled.name);
  if (ccdd != null) {
    final config2 = facade.storeValue(cardColorDarkDisabled, Color(ccdd));
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }

  final rt = storage.getBool(StorageAccessKey.runTogether.name);
  if (rt != null) {
    final config2 = facade.storeValue(runTogether, rt);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final mod = storage.getBool(StorageAccessKey.moveOnDrag.name);
  if (mod != null) {
    final config2 = facade.storeValue(moveOnDrag, mod);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final iea = storage.getString(StorageAccessKey.iniEditorArg.name);
  if (iea != null) {
    final config2 = facade.storeValue(iniEditorArg, iea);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final sfi = storage.getBool(StorageAccessKey.showFolderIcon.name);
  if (sfi != null) {
    final config2 = facade.storeValue(showFolderIcon, sfi);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final semf = storage.getBool(StorageAccessKey.showEnabledModsFirst.name);
  if (semf != null) {
    final config2 = facade.storeValue(showEnabledModsFirst, semf);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final dm = storage.getBool(StorageAccessKey.darkMode.name);
  if (dm != null) {
    final config2 = facade.storeValue(darkMode, dm);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final spaefi =
      storage.getBool(StorageAccessKey.showPaimonAsEmptyIconFolderIcon.name);
  if (spaefi != null) {
    final config2 = facade.storeValue(showPaimonAsEmptyIconFolderIcon, spaefi);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }
  final winWidth = storage.getString(StorageAccessKey.windowWidth.name);
  final winHeight = storage.getString(StorageAccessKey.windowHeight.name);
  if (winWidth != null && winHeight != null) {
    try {
      final config2 = facade.storeValue(
        windowSize,
        Size(double.parse(winWidth), double.parse(winHeight)),
      );
      config = config.copyWith(
        entry: {
          ...config.entry,
          ...config2.entry,
        },
      );
    } on FormatException {
      // ignore
    }
  }

  final cst = storage.getInt(StorageAccessKey.columnStrategyType.name);
  final csv = storage.getInt(StorageAccessKey.columnStrategyValue.name);
  if (cst != null && csv != null) {
    final mediator = switch (cst) {
      0 => ColumnStrategySettingMediator(
          current: const ColumnStrategyEntryEnum.fixedCount(),
          fixedCount: csv,
          maxExtent: 440,
          minExtent: 440,
        ),
      1 => ColumnStrategySettingMediator(
          current: const ColumnStrategyEntryEnum.maxExtent(),
          fixedCount: 3,
          maxExtent: csv,
          minExtent: 440,
        ),
      2 => ColumnStrategySettingMediator(
          current: const ColumnStrategyEntryEnum.minExtent(),
          fixedCount: 3,
          maxExtent: 440,
          minExtent: csv,
        ),
      _ => const ColumnStrategySettingMediator(
          current: ColumnStrategyEntryEnum.minExtent(),
          fixedCount: 3,
          maxExtent: 440,
          minExtent: 440,
        ),
    };
    final config2 = facade.storeValue(columnStrategy, mediator);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }

  final gameList = storage.getList('games');
  if (gameList != null) {
    final lastGame = storage.getString('lastGame');
    final gameMap = <String, GameConfig>{};
    for (final game in gameList) {
      final map = storage.getMap('$game.presetData');
      final preset = map == null ? null : PresetData.fromJson(map);
      final gameConfig = GameConfig(
        launcherFile: storage.getString('$game.launcherDir'),
        modExecFile: storage.getString('$game.modExecFile'),
        modRoot: storage.getString('$game.modRoot'),
        presetData: preset,
        separateRunOverride: storage.getBool('$game.overrideRun'),
      );
      gameMap[game] = gameConfig;
    }
    final game = GameConfigMediator(gameConfig: gameMap, current: lastGame);
    final config2 = facade.storeValue(games, game);
    config = config.copyWith(
      entry: {
        ...config.entry,
        ...config2.entry,
      },
    );
  }

  await repository.save(config);

  storage.setInt('didMigration', 1);
  return config;
}

void afterInitializationUseCase(final SharedPreferenceStorage storage) {
  var version = storage.getInt(configVersionKey);
  if (version == null) {
    if (storage.getEntries().isEmpty) {
      storage.setInt(configVersionKey, 2);
    } else {
      _convertToVersion1(storage);
    }
  }
  version = storage.getInt(configVersionKey);
  if (version == 1) {
    _convertToVersion2(storage);
  }
}

void _convertToVersion1(final SharedPreferenceStorage storage2) {
  const dotString = '.';
  final tDirRaw = storage2.getString('targetDir') ?? dotString;
  final targetDir = tDirRaw;

  var modRoot = _getModRootUseCase(storage2, targetDir);
  if (modRoot == null && targetDir != dotString) {
    modRoot = targetDir.pJoin('Mods');
  }

  var modExecFile = _getModExecFileUseCase(storage2, targetDir);
  if (modExecFile == null && targetDir != dotString) {
    modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
  }

  storage2
    ..removeKey('targetDir')
    ..setInt(configVersionKey, 1);
}

void _convertToVersion2(final SharedPreferenceStorage storage2) {
  final genshinModRoot = storage2.getString('modRoot') ?? '';
  final genshinModExecFile = storage2.getString('modExecFile') ?? '';
  final genshinLauncherDir = storage2.getString('launcherDir') ?? '';
  final genshinPresetData = storage2.getMap('presetData') ?? {};
  final starrailModRoot = storage2.getString('s_modRoot') ?? '';
  final starrailModExecFile = storage2.getString('s_modExecFile') ?? '';
  final starrailLauncherDir = storage2.getString('s_launcherDir') ?? '';
  final starrailPresetData = storage2.getMap('s_presetData') ?? {};
  storage2
    ..setList('games', ['Genshin', 'Starrail'])
    ..setString('lastGame', 'Genshin')
    ..setString('Genshin.modRoot', genshinModRoot)
    ..setString('Genshin.modExecFile', genshinModExecFile)
    ..setString('Genshin.launcherDir', genshinLauncherDir)
    ..setMap('Genshin.presetData', genshinPresetData)
    ..setString('Starrail.modRoot', starrailModRoot)
    ..setString('Starrail.modExecFile', starrailModExecFile)
    ..setString('Starrail.launcherDir', starrailLauncherDir)
    ..setMap('Starrail.presetData', starrailPresetData)
    ..setInt(configVersionKey, 2);
}

String? _getModRootUseCase(
  final SharedPreferenceStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modRoot');
String? _getModExecFileUseCase(
  final SharedPreferenceStorage storage,
  final String prefix,
) =>
    storage.getString('$prefix.modExecFile');
