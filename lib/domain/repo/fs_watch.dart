import 'dart:io';

abstract interface class FileSystemWatcher {
  Stream<FileSystemEvent?> get event;

  void dispose();
}

abstract interface class RecursiveFileSystemWatcher extends FileSystemWatcher {
  void cut();

  void uncut();

  void forceUpdate();
}
