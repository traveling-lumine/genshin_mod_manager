// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'akasha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NahidaliveElementImpl _$$NahidaliveElementImplFromJson(
        Map<String, dynamic> json) =>
    _$NahidaliveElementImpl(
      uuid: json['uuid'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      previewUrl: json['preview_url'] as String,
      arcaUrl: json['arcaUrl'] as String?,
      virustotalUrl: json['virustotalUrl'] as String?,
    );

Map<String, dynamic> _$$NahidaliveElementImplToJson(
        _$NahidaliveElementImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'version': instance.version,
      'title': instance.title,
      'description': instance.description,
      'tags': instance.tags,
      'preview_url': instance.previewUrl,
      'arcaUrl': instance.arcaUrl,
      'virustotalUrl': instance.virustotalUrl,
    };

_$NahidaliveDownloadElementImpl _$$NahidaliveDownloadElementImplFromJson(
        Map<String, dynamic> json) =>
    _$NahidaliveDownloadElementImpl(
      status: json['status'] as bool,
      errorCodes: json['error-codes'] as String?,
      downloadUrl: json['download_url'] as String?,
    );

Map<String, dynamic> _$$NahidaliveDownloadElementImplToJson(
        _$NahidaliveDownloadElementImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'error-codes': instance.errorCodes,
      'download_url': instance.downloadUrl,
    };