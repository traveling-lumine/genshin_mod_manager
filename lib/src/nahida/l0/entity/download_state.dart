import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
    required final bool writeSuccess,
    required final String fileName,
    final Exception? exception,
  }) = NahidaDownloadStateModZipExtractionException;
}
