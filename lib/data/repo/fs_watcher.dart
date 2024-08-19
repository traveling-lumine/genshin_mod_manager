import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';

class FolderWatcher<T extends FileSystemEntity> {
  FolderWatcher({
    required this.path,
    final bool watchModifications = false,
    final bool broadcast = false,
  }) : _controller = broadcast
            ? StreamController<List<String>>.broadcast()
            : StreamController<List<String>>() {
    _add(null);
    var events =
        FileSystemEvent.delete | FileSystemEvent.create | FileSystemEvent.move;
    if (watchModifications) {
      events |= FileSystemEvent.modify;
    }
    _subscription = Directory(path).watch(events: events).listen(_add);
  }

  final String path;
  final StreamController<List<String>> _controller;
  late final StreamSubscription<FileSystemEvent> _subscription;

  Stream<List<String>> get entities => _controller.stream;

  void _add(final FileSystemEvent? event) {
    final files = getUnderSync<T>(path);
    _controller.add(files);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
