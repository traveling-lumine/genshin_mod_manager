import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'akasha.freezed.dart';
part 'akasha.g.dart';

@freezed
class NahidaliveElement with _$NahidaliveElement {
  const factory NahidaliveElement({
    required final String uuid,
    required final String version,
    required final String title,
    required final String description,
    required final List<String> tags,
    @JsonKey(name: 'preview_url') required final String previewUrl,
    final String? arcaUrl,
    final String? virustotalUrl,
  }) = _NahidaliveElement;

  factory NahidaliveElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaliveElementFromJson(json);
}

@freezed
class NahidaliveDownloadElement with _$NahidaliveDownloadElement {
  const factory NahidaliveDownloadElement({
    required final bool status,
    @JsonKey(name: 'error-codes') final String? errorCodes,
    @JsonKey(name: 'download_url') final String? downloadUrl,
  }) = _NahidaliveDownloadElement;

  factory NahidaliveDownloadElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaliveDownloadElementFromJson(json);
}

// ignore_for_file: invalid_annotation_target
