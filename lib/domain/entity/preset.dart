// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset.freezed.dart';
part 'preset.g.dart';

@freezed
class PresetData with _$PresetData {
  const factory PresetData({
    required final Map<String, PresetListMap> global,
    required final Map<String, PresetListMap> local,
  }) = _PresetData;

  factory PresetData.fromJson(final Map<String, dynamic> json) =>
      _$PresetDataFromJson(json);
}

@freezed
class PresetListMap with _$PresetListMap {
  const factory PresetListMap({
    required final Map<String, PresetList> bundledPresets,
  }) = _PresetListMap;

  factory PresetListMap.fromJson(final Map<String, dynamic> json) =>
      _$PresetListMapFromJson(json);
}

@freezed
class PresetList with _$PresetList {
  const factory PresetList({
    required final List<String> mods,
  }) = _PresetList;

  factory PresetList.fromJson(
    final Map<String, dynamic> json,
  ) =>
      _$PresetListFromJson(json);
}
