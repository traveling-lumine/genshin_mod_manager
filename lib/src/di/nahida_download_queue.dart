import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/nahida/domain/entity/download_state.dart';
import '../backend/nahida/domain/entity/nahida_element.dart';
import '../backend/nahida/domain/entity/wrong_password.dart';
import '../backend/nahida/domain/usecase/download_url.dart';
import '../backend/mod_writer/data/mod_writer.dart';
import '../backend/structure/entity/mod_category.dart';
import 'nahida_store.dart';

part 'nahida_download_queue.g.dart';

@riverpod
class NahidaDownloadQueue extends _$NahidaDownloadQueue {
  StreamController<NahidaDownloadState>? _controller;

  @override
  Stream<NahidaDownloadState> build() {
    final controller = StreamController<NahidaDownloadState>();
    ref.onDispose(controller.close);
    _controller = controller;
    return controller.stream;
  }

  Future<void> addDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    final String? pw,
  }) async {
    final api = ref.read(nahidaApiProvider);
    final writer = createModWriter(categoryPath: category.path);
    var passwd = pw;
    while (true) {
      try {
        await nahidaDownloadUrlUseCase(
          api: api,
          element: element,
          writer: writer,
          pw: passwd,
        );
        break;
      } on HttpException catch (e) {
        _controller?.add(
          NahidaDownloadState.httpException(element: element, exception: e),
        );
        return;
      } on WrongPasswordException {
        final completer = Completer<String?>();
        _controller?.add(
          NahidaDownloadState.wrongPassword(
            element: element,
            wrongPw: passwd,
            completer: completer,
          ),
        );
        final password = await completer.future;
        if (password == null) {
          return;
        }
        passwd = password;
      } on ModZipExtractionException catch (e) {
        _controller?.add(
          NahidaDownloadState.modZipExtractionException(
            element: element,
            category: category,
            data: e.data,
          ),
        );
        return;
      }
    }
    _controller?.add(NahidaDownloadState.completed(element: element));
  }
}
