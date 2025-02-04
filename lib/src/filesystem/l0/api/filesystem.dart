import 'dart:async';
import 'dart:io';

import 'watcher.dart';

abstract interface class Filesystem {
  Watcher watchFile({
    required final String path,
    required final void Function(FileSystemEvent? event) onEvent,
  });

  Watcher watchDirectory({
    required final String path,
    required final void Function(FileSystemEvent? event) onEvent,
  });

  Future<void> pauseAllWatchers();

  void resumeAllWatchers();

  Future<void> dispose();
}
