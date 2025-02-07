import 'dart:io';

import '../../../fs_interface/helper/fsops.dart';
import '../../../fs_interface/repo/fs_interface.dart';
import '../../l0/api/filesystem.dart';
import '../../l0/api/folder_icon.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod_category.dart';

class FolderIconRepoImpl implements FolderIconRepo {
  factory FolderIconRepoImpl({
    required final Filesystem fs,
    required final FileSystemInterface fsi,
    required final ModCategory category,
  }) {
    final path = (fsi.iconDir(category.name)..createSync(recursive: true)).path;
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

    return FolderIconRepoImpl._(
      watcher: watcher,
      stream: stream,
    );
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
