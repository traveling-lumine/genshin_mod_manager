import 'package:fluent_ui/fluent_ui.dart';

import 'app_config_entry.dart';
import 'column_strategy.dart';
import 'entry_helpers.dart';
import 'game_config.dart';

final AppConfigEntry<Color> cardColorBrightEnabled = colorEntry(
  key: 'cardColorBrightEnabled',
  defaultValue: Colors.green.lightest,
);
final AppConfigEntry<Color> cardColorBrightDisabled = colorEntry(
  key: 'cardColorBrightDisabled',
  defaultValue: Colors.red.lightest.withValues(alpha: 0.5),
);
final AppConfigEntry<Color> cardColorDarkEnabled = colorEntry(
  key: 'cardColorDarkEnabled',
  defaultValue: Colors.green.darkest.withValues(alpha: 0.8),
);
final AppConfigEntry<Color> cardColorDarkDisabled = colorEntry(
  key: 'cardColorDarkDisabled',
  defaultValue: Colors.red.darkest.withValues(alpha: 0.5),
);

final AppConfigEntry<bool> runTogether =
    boolEntry(key: 'runTogether', defaultValue: false);

final AppConfigEntry<bool> moveOnDrag =
    boolEntry(key: 'moveOnDrag', defaultValue: true);

final AppConfigEntry<String?> iniEditorArg =
    nullableStringEntry(key: 'iniEditorArg', defaultValue: null);

final AppConfigEntry<bool> showFolderIcon =
    boolEntry(key: 'showFolderIcon', defaultValue: true);

final AppConfigEntry<bool> showEnabledModsFirst =
    boolEntry(key: 'showEnabledModsFirst', defaultValue: true);

final AppConfigEntry<bool> darkMode =
    boolEntry(key: 'darkMode', defaultValue: true);

final AppConfigEntry<bool> showPaimonAsEmptyIconFolderIcon =
    boolEntry(key: 'showPaimonAsEmptyIconFolderIcon', defaultValue: false);

final windowSize = AppConfigEntry<Size?>(
  key: 'windowSize',
  defaultValue: null,
  fromJson: (final dynamic json) {
    if (json is Map<String, dynamic>) {
      return Size(
        doubleConverter(json['width']),
        doubleConverter(json['height']),
      );
    }
    throw Exception('Invalid json type for windowSize');
  },
  toJson: (final value) {
    if (value == null) {
      return null;
    }
    return {
      'width': value.width,
      'height': value.height,
    };
  },
);

final columnStrategy = AppConfigEntry<ColumnStrategySettingMediator>(
  key: 'columnStrategy',
  defaultValue: const ColumnStrategySettingMediator(
    current: ColumnStrategyEntryMinExtent(),
    fixedCount: 3,
    maxExtent: 440,
    minExtent: 440,
  ),
  fromJson: (final dynamic json) =>
      ColumnStrategySettingMediator.fromJson(json as Map<String, dynamic>),
  toJson: (final value) => value.toJson(),
);

final games = AppConfigEntry<GameConfigMediator>(
  key: 'gameConfig',
  defaultValue: const GameConfigMediator(current: '', gameConfig: {}),
  fromJson: (final dynamic json) =>
      GameConfigMediator.fromJson(json as Map<String, dynamic>),
  toJson: (final value) => value.toJson(),
);
