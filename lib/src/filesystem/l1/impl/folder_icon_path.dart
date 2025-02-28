import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/filesystem.dart';
import '../../l0/api/folder_icon_path.dart';
import '../../l0/entity/mod_category.dart';
import '../helper.dart';

class FolderIconPathImpl implements FolderIconPath {
  factory FolderIconPathImpl({
    required final String currentGame,
    required final Filesystem fs,
    required final ModCategory category,
  }) {
    final iconPath = p.join(
      File(Platform.resolvedExecutable).parent.path,
      'Resources',
      currentGame,
    );

    final streamCompleter = Completer<Stream<String?>>();
    final watcherCompleter = Completer<Future<void> Function()>();

    unawaited(
      Directory(iconPath).create(recursive: true).then<void>(
        (final value) {
          final watcher = fs.watchDirectory(path: iconPath);
          final stream = watcher.stream
              .debounceTime(const Duration(milliseconds: 100))
              .asyncMap(
            (final event) async {
              final s = await findPreviewPath(
                iconPath,
                name: category.name,
              );
              return s;
            },
          );

          streamCompleter.complete(stream);
          watcherCompleter.complete(watcher.cancel);
        },
      ).onError(watcherCompleter.completeError),
    );

    return FolderIconPathImpl._(
      path: streamCompleter.future.asStream().asyncExpand((final e) => e),
      onDispose: () async {
        await (await watcherCompleter.future)();
      },
    );
  }

  const FolderIconPathImpl._({
    required this.path,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<String?> path;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }
}
