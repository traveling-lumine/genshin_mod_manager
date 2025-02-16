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
    final rawJsonGlobal = json['global'];
    final rawJsonLocal = json['local'];
    final jsonGlobal = rawJsonGlobal is Map<String, dynamic>
        ? rawJsonGlobal
        : <String, dynamic>{};
    final jsonLocal = rawJsonLocal is Map<String, dynamic>
        ? rawJsonLocal
        : <String, dynamic>{};
    final global = {
      for (final MapEntry(:key, :value) in jsonGlobal.entries)
        key: PresetListMap.fromJson(value as Map<String, dynamic>),
    };
    final local = {
      for (final MapEntry(:key, :value) in jsonLocal.entries)
        key: PresetListMap.fromJson(value as Map<String, dynamic>),
    };
    return PresetData(global: global, local: local);
  }

  const PresetData._();

  Map<String, Map<String, Map<String, List<String>>>> toJson() {
    final globalMap = {
      for (final MapEntry(:key, :value) in global.entries)
        if (value.bundledPresets.isNotEmpty) key: value.toJson(),
    };
    final localMap = {
      for (final MapEntry(:key, :value) in local.entries)
        if (value.bundledPresets.isNotEmpty) key: value.toJson(),
    };
    return {
      if (globalMap.isNotEmpty) 'global': globalMap,
      if (localMap.isNotEmpty) 'local': localMap,
    };
  }
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
