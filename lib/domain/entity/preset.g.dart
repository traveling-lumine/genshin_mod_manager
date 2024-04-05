// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresetDataImpl _$$PresetDataImplFromJson(Map<String, dynamic> json) =>
    _$PresetDataImpl(
      global: (json['global'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, PresetListMap.fromJson(e as Map<String, dynamic>)),
      ),
      local: (json['local'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, PresetListMap.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$PresetDataImplToJson(_$PresetDataImpl instance) =>
    <String, dynamic>{
      'global': instance.global,
      'local': instance.local,
    };

_$PresetListMapImpl _$$PresetListMapImplFromJson(Map<String, dynamic> json) =>
    _$PresetListMapImpl(
      bundledPresets: (json['bundledPresets'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PresetList.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$PresetListMapImplToJson(_$PresetListMapImpl instance) =>
    <String, dynamic>{
      'bundledPresets': instance.bundledPresets,
    };

_$PresetListImpl _$$PresetListImplFromJson(Map<String, dynamic> json) =>
    _$PresetListImpl(
      mods: (json['mods'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PresetListImplToJson(_$PresetListImpl instance) =>
    <String, dynamic>{
      'mods': instance.mods,
    };
