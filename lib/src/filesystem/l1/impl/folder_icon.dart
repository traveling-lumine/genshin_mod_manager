import 'dart:io';

import '../../l0/api/filesystem.dart';
import '../../l0/api/folder_icon.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod_category.dart';
import 'fsops.dart';

class FolderIconRepoImpl implements FolderIconRepo {
  factory FolderIconRepoImpl({
    required final Filesystem fs,
    required final Directory iconDir,
    required final ModCategory category,
  }) {
    final path = (iconDir..createSync(recursive: true)).path;
    final Watcher watcher;
    try {
      watcher = fs.watchFile(path: path);
    } on FileSystemException catch (_) {
      return FolderIconRepoImpl._(
        stream: Stream.value(null).asBroadcastStream(),
      );
    }
    final stream = watcher.stream.asyncMap(
      (final event) async => findPreviewFileInString(
        await getUnder<File>(path),
        name: category.name,
      ),
    );

    return FolderIconRepoImpl._(watcher: watcher, stream: stream);
  }
  FolderIconRepoImpl._({
    required this.stream,
    this.watcher,
  });
  final Watcher? watcher;

  @override
  final Stream<String?> stream;

  @override
  Future<void> dispose() async {
    await watcher?.cancel();
  }
}
