import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../filesystem/l0/entity/mod_category.dart';
import 'nahida_element.dart';

part 'download_state.freezed.dart';

@freezed
sealed class NahidaDownloadState with _$NahidaDownloadState {
  const factory NahidaDownloadState.completed({
    required final NahidaliveElement element,
  }) = NahidaDownloadStateCompleted;

  const factory NahidaDownloadState.wrongPassword({
    required final NahidaliveElement element,
    final String? wrongPw,
  }) = NahidaDownloadStateWrongPassword;

  const factory NahidaDownloadState.modZipExtractionException({
    required final NahidaliveElement element,
    required final ModCategory category,
    required final Uint8List data,
  }) = NahidaDownloadStateModZipExtractionException;
}
