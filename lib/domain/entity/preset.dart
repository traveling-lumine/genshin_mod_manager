// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset.freezed.dart';
part 'preset.g.dart';

@freezed
class PresetData with _$PresetData {
  const factory PresetData({
    required final Map<String, BundledPresetData> global,
    required final Map<String, BundledPresetData> local,
  }) = _PresetData;

  factory PresetData.fromJson(final Map<String, dynamic> json) =>
      _$PresetDataFromJson(json);
}

@freezed
class BundledPresetData with _$BundledPresetData {
  const factory BundledPresetData({
    required final Map<String, PresetTargetData> bundledPresets,
  }) = _BundledPresetData;

  factory BundledPresetData.fromJson(final Map<String, dynamic> json) =>
      _$BundledPresetDataFromJson(json);
}

@freezed
class PresetTargetData with _$PresetTargetData {
  const factory PresetTargetData({
    required final List<String> mods,
  }) = _PresetTargetData;

  factory PresetTargetData.fromJson(
    final Map<String, dynamic> json,
  ) =>
      _$PresetTargetDataFromJson(json);
}
