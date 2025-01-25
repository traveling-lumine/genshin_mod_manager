import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/stream.dart';
import '../entity/download_state.dart';

part 'nahida_download_queue.g.dart';

@riverpod
class NahidaDownloadQueue extends _$NahidaDownloadQueue
    implements NahidaDownloadStatusQueue {
  StreamController<NahidaDownloadState>? _controller;

  @override
  Stream<NahidaDownloadState> build() {
    final ctrl = StreamController<NahidaDownloadState>();
    ref.onDispose(ctrl.close);
    _controller = ctrl;
    return ctrl.stream;
  }

  @override
  void add(final NahidaDownloadState event) {
    _controller?.add(event);
  }
}
