import 'dart:io';

abstract interface class FileEvent {
  Stream<FileSystemEvent?> get stream;
  Future<void> cancel();
}
