import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config_entry.freezed.dart';

@freezed
class AppConfigEntry<T> with _$AppConfigEntry<T> {
  const factory AppConfigEntry({
    required final String key,
    required final T defaultValue,
    required final T Function(dynamic value) fromJson,
    required final dynamic Function(T value) toJson,
  }) = _AppConfigEntry;
}
