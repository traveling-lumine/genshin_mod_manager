import 'dart:async';

import 'watcher.dart';

abstract interface class Filesystem {
  Watcher watchFile({
    required final String path,
  });

  Watcher watchDirectory({
    required final String path,
  });

  Future<void> pauseAllWatchers();

  void resumeAllWatchers();

  Future<void> dispose();
}
