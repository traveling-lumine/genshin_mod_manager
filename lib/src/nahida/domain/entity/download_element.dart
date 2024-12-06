// As required in the package
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_element.freezed.dart';
part 'download_element.g.dart';

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
