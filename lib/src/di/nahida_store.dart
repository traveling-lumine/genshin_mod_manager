import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/akasha/data/repo/akasha.dart';
import '../backend/akasha/domain/entity/nahida_element.dart';
import '../backend/akasha/domain/repo/akasha.dart';
import '../backend/akasha/domain/usecase/download_url.dart';
import '../backend/mod_writer/data/mod_writer.dart';
import '../backend/structure/entity/mod_category.dart';

part 'nahida_store.g.dart';

@Riverpod(keepAlive: true)
NahidaliveAPI akashaApi(final AkashaApiRef ref) => createNahidaliveAPI();

@Riverpod(keepAlive: true)
NahidaDownloadModel downloadModel(final DownloadModelRef ref) {
  final api = ref.watch(akashaApiProvider);
  return NahidaDownloadModel(api);
}

final class NahidaDownloadModel {
  NahidaDownloadModel(this.api);

  final NahidaliveAPI api;

  Future<String?> Function(String?)? _onPasswordRequired;
  void Function(HttpException)? _onApiException;
  void Function(NahidaliveElement)? _onDownloadComplete;
  void Function(ModCategory, String, Uint8List)? _onExtractFail;

  Future<void> onModDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    String? pw,
  }) async {
    final writer = createModWriter(category: category);
    while (true) {
      try {
        await AkashaDownloadUrlUseCase(
          api: api,
          element: element,
          writer: writer,
          pw: pw,
        ).call();
        break;
      } on HttpException catch (e) {
        _onApiException?.call(e);
        return;
      } on WrongPasswordException {
        final password = await _onPasswordRequired?.call(pw);
        if (password == null) {
          return;
        }
        pw = password;
      } on ModZipExtractionException catch (e) {
        _onExtractFail?.call(category, element.title, e.data);
        return;
      }
    }
    _onDownloadComplete?.call(element);
  }

  void registerDownloadCallbacks({
    final Future<String?> Function(String?)? onPasswordRequired,
    final void Function(HttpException)? onApiException,
    final void Function(NahidaliveElement)? onDownloadComplete,
    final void Function(ModCategory, String, Uint8List)? onExtractFail,
  }) {
    _onPasswordRequired = onPasswordRequired;
    _onApiException = onApiException;
    _onDownloadComplete = onDownloadComplete;
    _onExtractFail = onExtractFail;
  }
}
