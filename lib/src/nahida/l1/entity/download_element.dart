// As required in the package
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_element.freezed.dart';
part 'download_element.g.dart';

@freezed
class NahidaDownloadUrlElement with _$NahidaDownloadUrlElement {
  const factory NahidaDownloadUrlElement({
    @JsonKey(name: 'presigned_url') final String? downloadUrl,
    @JsonKey(name: 'file_name') final String? fileName,
    @JsonKey(name: 'uuid') final String? uuid,
    final bool? success,
    final NahidaDownloadUrlError? error,
  }) = _NahidaDownloadUrlElement;

  factory NahidaDownloadUrlElement.fromJson(final Map<String, dynamic> json) =>
      _$NahidaDownloadUrlElementFromJson(json);
}

@freezed
class NahidaDownloadUrlError with _$NahidaDownloadUrlError {
  const factory NahidaDownloadUrlError({
    required final String code,
    required final String message,
  }) = _NahidaDownloadUrlError;

  factory NahidaDownloadUrlError.fromJson(final Map<String, dynamic> json) =>
      _$NahidaDownloadUrlErrorFromJson(json);
}
