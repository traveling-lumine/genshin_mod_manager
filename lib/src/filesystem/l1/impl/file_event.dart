import 'dart:io';

import '../../l0/api/file_event.dart';
import '../../l0/api/filesystem.dart';
import '../../l0/api/watcher.dart';

class FileEventImpl implements FileEvent {
  factory FileEventImpl({
    required final Filesystem fs,
    required final String path,
  }) {
    final watcher = fs.watchFile(path: path);
    return FileEventImpl._(
      watcher: watcher,
      stream: watcher.stream,
    );
  }

  FileEventImpl._({
    required this.watcher,
    required this.stream,
  });

  final Watcher watcher;

  @override
  Future<void> cancel() async {
    await watcher.cancel();
  }

  @override
  final Stream<FileSystemEvent?> stream;
}
