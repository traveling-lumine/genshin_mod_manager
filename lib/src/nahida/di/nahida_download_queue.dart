import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../mod_writer/data/mod_writer.dart';
import '../../structure/entity/mod_category.dart';
import '../domain/entity/download_state.dart';
import '../domain/entity/nahida_element.dart';
import '../domain/entity/wrong_password.dart';
import '../domain/repo/nahida.dart';
import '../domain/usecase/download_url.dart';
import 'nahida_store.dart';

part 'nahida_download_queue.g.dart';

@riverpod
class NahidaDownloadQueue extends _$NahidaDownloadQueue {
  StreamController<NahidaDownloadState>? _controller;

  @override
  Stream<NahidaDownloadState> build() {
    final ctrl = StreamController<NahidaDownloadState>();
    ref.onDispose(ctrl.close);
    _controller = ctrl;
    return ctrl.stream;
  }

  Future<void> addDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    required final String turnstile,
    final String? pw,
  }) async {
    final api = ref.read(nahidaApiProvider);
    await _addDownload(
      element: element,
      category: category,
      turnstile: turnstile,
      api: api,
      controller: _controller,
      pw: pw,
    );
  }
}

Future<void> _addDownload({
  required final NahidaliveElement element,
  required final ModCategory category,
  required final String turnstile,
  required final NahidaliveAPI api,
  required final StreamController<NahidaDownloadState>? controller,
  final String? pw,
}) async {
  if (element.password && pw == null) {
    _getPassword(element, pw, controller);
    return;
  }
  final writer = createModWriter(categoryPath: category.path);

  try {
    await nahidaDownloadUrlUseCase(
      api: api,
      element: element,
      writer: writer,
      turnstile: turnstile,
      pw: pw,
    );
  } on DioException catch (e) {
    switch (e.error) {
      case WrongPasswordException _:
        _getPassword(element, pw, controller);
        return;
    }
  } on ModZipExtractionException catch (e) {
    _addModExtractionException(element, category, e, controller);
    return;
  }
  controller?.add(NahidaDownloadState.completed(element: element));
}

void _addModExtractionException(
  final NahidaliveElement element,
  final ModCategory category,
  final ModZipExtractionException e,
  final StreamController<NahidaDownloadState>? controller,
) {
  controller?.add(
    NahidaDownloadState.modZipExtractionException(
      element: element,
      category: category,
      data: e.data,
    ),
  );
}

void _getPassword(
  final NahidaliveElement element,
  final String? passwd,
  final StreamController<NahidaDownloadState>? controller,
) {
  controller?.add(
    NahidaDownloadState.wrongPassword(
      element: element,
      wrongPw: passwd,
    ),
  );
}
