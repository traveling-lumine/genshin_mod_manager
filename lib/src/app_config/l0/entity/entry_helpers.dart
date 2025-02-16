import 'dart:ui';

import 'app_config_entry.dart';

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

double doubleConverter(final dynamic value) {
  if (value is double) {
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
