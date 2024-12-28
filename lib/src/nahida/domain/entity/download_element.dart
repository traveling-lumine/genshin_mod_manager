// As required in the package
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_element.freezed.dart';
part 'download_element.g.dart';

@freezed
class NahidaliveDownloadUrlElement with _$NahidaliveDownloadUrlElement {
  const factory NahidaliveDownloadUrlElement({
    @JsonKey(name: 'presigned_url') required final String downloadUrl,
    @JsonKey(name: 'file_name') required final String fileName,
    @JsonKey(name: 'uuid') required final String uuid,
  }) = _NahidaliveDownloadUrlElement;

  factory NahidaliveDownloadUrlElement.fromJson(
          final Map<String, dynamic> json) =>
      _$NahidaliveDownloadUrlElementFromJson(json);
}
