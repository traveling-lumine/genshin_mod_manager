import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config.freezed.dart';

@freezed
class AppConfig with _$AppConfig {
  const factory AppConfig(final Map<String, dynamic> entry) = _AppConfig;
  const AppConfig._();

  factory AppConfig.fromJson(final Map<String, dynamic> json) = AppConfig;

  Map<String, dynamic> toJson() => entry;
}
