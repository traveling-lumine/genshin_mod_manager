// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PresetDataImpl _$$PresetDataImplFromJson(Map<String, dynamic> json) =>
    _$PresetDataImpl(
      global: (json['global'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, BundledPresetData.fromJson(e as Map<String, dynamic>)),
      ),
      local: (json['local'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, BundledPresetData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$PresetDataImplToJson(_$PresetDataImpl instance) =>
    <String, dynamic>{
      'global': instance.global,
      'local': instance.local,
    };

_$BundledPresetDataImpl _$$BundledPresetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BundledPresetDataImpl(
      bundledPresets: (json['bundledPresets'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, PresetTargetData.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$BundledPresetDataImplToJson(
        _$BundledPresetDataImpl instance) =>
    <String, dynamic>{
      'bundledPresets': instance.bundledPresets,
    };

_$PresetTargetDataImpl _$$PresetTargetDataImplFromJson(
        Map<String, dynamic> json) =>
    _$PresetTargetDataImpl(
      mods: (json['mods'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PresetTargetDataImplToJson(
        _$PresetTargetDataImpl instance) =>
    <String, dynamic>{
      'mods': instance.mods,
    };
