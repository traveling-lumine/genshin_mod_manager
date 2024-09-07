import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/akasha/domain/entity/download_state.dart';
import '../backend/akasha/domain/entity/nahida_element.dart';
import '../backend/akasha/domain/entity/wrong_password.dart';
import '../backend/akasha/domain/usecase/download_url.dart';
import '../backend/mod_writer/data/mod_writer.dart';
import '../backend/structure/entity/mod_category.dart';
import 'nahida_store.dart';

part 'akasha_download_queue.g.dart';

@riverpod
class AkashaDownloadQueue extends _$AkashaDownloadQueue {
  StreamController<AkashaDownloadState>? _controller;

  @override
  Stream<AkashaDownloadState> build() {
    final controller = StreamController<AkashaDownloadState>();
    ref.onDispose(controller.close);
    _controller = controller;
    return controller.stream;
  }

  Future<void> addDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    final String? pw,
  }) async {
    final api = ref.read(akashaApiProvider);
    final writer = createModWriter(category: category);
    var passwd = pw;
    while (true) {
      try {
        await akashaDownloadUrlUseCase(
          api: api,
          element: element,
          writer: writer,
          pw: passwd,
        );
        break;
      } on HttpException catch (e) {
        _controller?.add(
          AkashaDownloadState.httpException(element: element, exception: e),
        );
        return;
      } on WrongPasswordException {
        final completer = Completer<String?>();
        _controller?.add(
          AkashaDownloadState.wrongPassword(
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
          AkashaDownloadState.modZipExtractionException(
            element: element,
            category: category,
            data: e.data,
          ),
        );
        return;
      }
    }
    _controller?.add(AkashaDownloadState.completed(element: element));
  }
}
