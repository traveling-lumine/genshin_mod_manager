// ignore_for_file: invalid_annotation_target

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
    required final List<String> tags,
    @JsonKey(name: 'preview_url') required final String previewUrl,
    final String? description,
    @JsonKey(name: 'arca_url') final String? arcaUrl,
    @JsonKey(name: 'virustotal_url') final String? virustotalUrl,
  }) = _NahidaliveElement;

  factory NahidaliveElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaliveElementFromJson(json);
}

@freezed
class NahidaliveDownloadElement with _$NahidaliveDownloadElement {
  const factory NahidaliveDownloadElement({
    required final bool success,
    @JsonKey(name: 'error-codes') final String? errorCodes,
    @JsonKey(name: 'presigned_url') final String? downloadUrl,
  }) = _NahidaliveDownloadElement;

  factory NahidaliveDownloadElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaliveDownloadElementFromJson(json);
}
