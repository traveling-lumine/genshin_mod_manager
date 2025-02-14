import 'dart:ui';

import '../../l0/entity/app_config_entry.dart';

String _stringConverter(final dynamic value) {
  if (value is String) {
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

int _intConverter(final dynamic value) {
  if (value is int) {
    return value;
  }
  throw Exception('Invalid value type');
}

bool _boolConverter(final dynamic value) {
  if (value is bool) {
    return value;
  }
  throw Exception('Invalid value type');
}

T _identity<T>(final T value) => value;

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
        if (value is int) {
          return Color(value);
        }
        throw Exception('Invalid value type');
      },
      toJson: (final value) => value.value,
    );
