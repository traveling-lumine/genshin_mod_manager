import 'package:fluent_ui/fluent_ui.dart';

import 'app_config_entry.dart';
import 'column_strategy.dart';
import 'game_config.dart';

final AppConfigEntry<Color> cardColorBrightDisabled = colorEntry(
  key: 'cardColorBrightDisabled',
  defaultValue: Colors.red.lightest.withValues(alpha: 0.5),
);

final AppConfigEntry<Color> cardColorBrightEnabled = colorEntry(
  key: 'cardColorBrightEnabled',
  defaultValue: Colors.green.lightest,
);

final AppConfigEntry<Color> cardColorDarkDisabled = colorEntry(
  key: 'cardColorDarkDisabled',
  defaultValue: Colors.red.darkest.withValues(alpha: 0.5),
);

final AppConfigEntry<Color> cardColorDarkEnabled = colorEntry(
  key: 'cardColorDarkEnabled',
  defaultValue: Colors.green.darkest.withValues(alpha: 0.8),
);

final columnStrategy = AppConfigEntry<ColumnStrategySettingMediator>(
  key: 'columnStrategy',
  defaultValue: const ColumnStrategySettingMediator(
    current: ColumnStrategyEnumType.minExtent,
    fixedCount: 3,
    maxExtent: 440,
    minExtent: 440,
  ),
  fromJson: (final dynamic json) =>
      ColumnStrategySettingMediator.fromJson(json as Map<String, dynamic>),
  toJson: (final value) => value.toJson(),
);

final AppConfigEntry<bool> darkMode =
    boolEntry(key: 'darkMode', defaultValue: true);

final games = AppConfigEntry<GameConfigMediator>(
  key: 'gameConfig',
  defaultValue: const GameConfigMediator(current: '', gameConfig: {}),
  fromJson: (final dynamic json) =>
      GameConfigMediator.fromJson(json as Map<String, dynamic>),
  toJson: (final value) => value.toJson(),
);

final AppConfigEntry<String?> iniEditorArg =
    nullableStringEntry(key: 'iniEditorArg', defaultValue: null);

final AppConfigEntry<bool> moveOnDrag =
    boolEntry(key: 'moveOnDrag', defaultValue: true);

final AppConfigEntry<bool> runTogether =
    boolEntry(key: 'runTogether', defaultValue: false);

final AppConfigEntry<bool> showEnabledModsFirst =
    boolEntry(key: 'showEnabledModsFirst', defaultValue: true);

final AppConfigEntry<bool> showFolderIcon =
    boolEntry(key: 'showFolderIcon', defaultValue: true);
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
AppConfigEntry<bool> boolEntry({
  required final String key,
  required final bool defaultValue,
}) =>
    AppConfigEntry<bool>(
      key: key,
      defaultValue: defaultValue,
      fromJson: _boolConverter,
      toJson: _identity,
    );

AppConfigEntry<Color> colorEntry({
  required final String key,
  required final Color defaultValue,
}) =>
    AppConfigEntry<Color>(
      key: key,
      defaultValue: defaultValue,
      fromJson: (final dynamic value) {
        if (value is Map<String, dynamic>) {
          return Color.from(
            alpha: doubleConverter(value['a']),
            red: doubleConverter(value['r']),
            green: doubleConverter(value['g']),
            blue: doubleConverter(value['b']),
          );
        }
        throw Exception('Invalid value type');
      },
      toJson: (final value) => {
        'r': value.r,
        'g': value.g,
        'b': value.b,
        'a': value.a,
      },
    );

double doubleConverter(final dynamic value) {
  if (value is double) {
    return value;
  }
  throw Exception('Invalid value type');
}

AppConfigEntry<int> intEntry({
  required final String key,
  required final int defaultValue,
}) =>
    AppConfigEntry<int>(
      key: key,
      defaultValue: defaultValue,
      fromJson: _intConverter,
      toJson: _identity,
    );

AppConfigEntry<String?> nullableStringEntry({
  required final String key,
  required final String? defaultValue,
}) =>
    AppConfigEntry<String?>(
      key: key,
      defaultValue: defaultValue,
      fromJson: _nullableStringConverter,
      toJson: _identity,
    );

AppConfigEntry<String> stringEntry({
  required final String key,
  required final String defaultValue,
}) =>
    AppConfigEntry<String>(
      key: key,
      defaultValue: defaultValue,
      fromJson: _stringConverter,
      toJson: _identity,
    );

bool _boolConverter(final dynamic value) {
  if (value is bool) {
    return value;
  }
  throw Exception('Invalid value type');
}

T _identity<T>(final T value) => value;

int _intConverter(final dynamic value) {
  if (value is int) {
    return value;
  }
  throw Exception('Invalid value type');
}

String? _nullableStringConverter(final dynamic value) {
  if (value is String?) {
    return value;
  }
  throw Exception('Invalid value type');
}

String _stringConverter(final dynamic value) {
  if (value is String) {
    return value;
  }
  throw Exception('Invalid value type');
}
