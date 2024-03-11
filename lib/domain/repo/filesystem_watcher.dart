import 'dart:io';

import 'package:genshin_mod_manager/domain/repo/disposable.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';

abstract interface class FSEventWatcher implements Disposable {
  LatestStream<FileSystemEvent?> get event;
}

abstract interface class RecursiveFileSystemWatcher extends FSEventWatcher {
  void cut();

  void uncut();

  void forceUpdate();
}

abstract interface class FSEntityWatcher<T extends FileSystemEntity>
    implements Disposable {
  LatestStream<List<T>> get entity;
}
