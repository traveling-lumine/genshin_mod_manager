import 'dart:io';

abstract interface class Watcher {
  Stream<FileSystemEvent?> get stream;

  Future<void> cancel();
}
