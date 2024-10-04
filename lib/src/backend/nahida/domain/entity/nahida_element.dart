// As required in the package
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'nahida_element.freezed.dart';
part 'nahida_element.g.dart';

@freezed
class NahidaliveElement with _$NahidaliveElement {
  const factory NahidaliveElement({
    required final String uuid,
    required final String version,
    required final String title,
    required final List<String> tags,
    @JsonKey(name: 'preview_url') required final String previewUrl,
    required final bool password,
    final String? description,
    @JsonKey(name: 'arca_url') final String? arcaUrl,
    @JsonKey(name: 'virustotal_url') final String? virustotalUrl,
    @JsonKey(name: 'expires_at') final int? expiresAt,
  }) = _NahidaliveElement;

  factory NahidaliveElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaliveElementFromJson(json);
}
