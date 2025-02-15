import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset.freezed.dart';

@freezed
class PresetData with _$PresetData {
  const factory PresetData({
    required final Map<String, PresetListMap> global,
    required final Map<String, PresetListMap> local,
  }) = _PresetData;
  factory PresetData.fromJson(final Map<String, dynamic> json) {
    final global = {
      for (final MapEntry(:key, :value)
          in (json['global'] as Map<String, dynamic>).entries)
        key: PresetListMap.fromJson(value as Map<String, dynamic>),
    };
    final local = {
      for (final MapEntry(:key, :value)
          in (json['local'] as Map<String, dynamic>).entries)
        key: PresetListMap.fromJson(value as Map<String, dynamic>),
    };
    return PresetData(global: global, local: local);
  }

  const PresetData._();

  Map<String, dynamic> toJson() => {
        'global': {
          for (final MapEntry(:key, :value) in global.entries)
            key: value.toJson(),
        },
        'local': {
          for (final MapEntry(:key, :value) in local.entries)
            key: value.toJson(),
        },
      };
}

@freezed
class PresetList with _$PresetList {
  const factory PresetList({
    required final List<String> mods,
  }) = _PresetList;
  factory PresetList.fromJson(final dynamic json) {
    if (json is List) {
      return PresetList(mods: List<String>.from(json));
    }
    throw Exception('Invalid value type');
  }

  const PresetList._();

  List<String> toJson() => mods;
}

@freezed
class PresetListMap with _$PresetListMap {
  const factory PresetListMap({
    required final Map<String, PresetList> bundledPresets,
  }) = _PresetListMap;
  factory PresetListMap.fromJson(final Map<String, dynamic> json) {
    final map = {
      for (final MapEntry(:key, :value) in json.entries)
        key: PresetList.fromJson(value),
    };
    return PresetListMap(bundledPresets: map);
  }

  const PresetListMap._();

  Map<String, List<String>> toJson() => {
        for (final MapEntry(:key, :value) in bundledPresets.entries)
          key: value.toJson(),
      };
}
