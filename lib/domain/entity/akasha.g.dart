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
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      previewUrl: json['preview_url'] as String,
      description: json['description'] as String?,
      arcaUrl: json['arca_url'] as String?,
      virustotalUrl: json['virustotal_url'] as String?,
    );

Map<String, dynamic> _$$NahidaliveElementImplToJson(
        _$NahidaliveElementImpl instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'version': instance.version,
      'title': instance.title,
      'tags': instance.tags,
      'preview_url': instance.previewUrl,
      'description': instance.description,
      'arca_url': instance.arcaUrl,
      'virustotal_url': instance.virustotalUrl,
    };

_$NahidaliveDownloadElementImpl _$$NahidaliveDownloadElementImplFromJson(
        Map<String, dynamic> json) =>
    _$NahidaliveDownloadElementImpl(
      success: json['success'] as bool,
      errorCodes: json['error-codes'] as String?,
      downloadUrl: json['presigned_url'] as String?,
    );

Map<String, dynamic> _$$NahidaliveDownloadElementImplToJson(
        _$NahidaliveDownloadElementImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'error-codes': instance.errorCodes,
      'presigned_url': instance.downloadUrl,
    };
