import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../structure/entity/mod_category.dart';
import 'nahida_element.dart';

part 'download_state.freezed.dart';

@freezed
sealed class AkashaDownloadState with _$AkashaDownloadState {
  const factory AkashaDownloadState.completed({
    required final NahidaliveElement element,
  }) = AkashaDownloadStateCompleted;

  const factory AkashaDownloadState.wrongPassword({
    required final NahidaliveElement element,
    required final Completer<String?> completer,
    final String? wrongPw,
  }) = AkashaDownloadStateWrongPassword;

  const factory AkashaDownloadState.httpException({
    required final NahidaliveElement element,
    required final HttpException exception,
  }) = AkashaDownloadStateHttpException;

  const factory AkashaDownloadState.modZipExtractionException({
    required final NahidaliveElement element,
    required final ModCategory category,
    required final Uint8List data,
  }) = AkashaDownloadStateModZipExtractionException;
}
