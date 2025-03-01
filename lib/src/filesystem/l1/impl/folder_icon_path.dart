import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/filesystem.dart';
import '../../l0/api/folder_icon_path.dart';
import '../../l0/api/watcher.dart';
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

    final streamController = StreamController<String?>();
    StreamSubscription<String?>? subscription;
    Watcher? watcher;

    unawaited(
      Directory(iconPath).create(recursive: true).then<void>(
        (final _) async {
          final s = await findPreviewPath(
            iconPath,
            name: category.name,
          );
          if (streamController.isClosed) {
            return;
          }
          streamController.add(s);

          final lWatcher = watcher = fs.watchDirectory(path: iconPath);
          try {
            subscription = lWatcher.stream
                .debounceTime(const Duration(milliseconds: 100))
                .asyncMap(
                  (final _) => findPreviewPath(
                    iconPath,
                    name: category.name,
                  ),
                )
                .listen(
                  streamController.add,
                  onError: streamController.addError,
                  onDone: streamController.close,
                );
          } on Exception catch (e, st) {
            await lWatcher.cancel();
            streamController.addError(e, st);
          }
        },
      ).onError(streamController.addError),
    );

    return FolderIconPathImpl._(
      path: streamController.stream,
      onDispose: () async {
        await watcher?.cancel();
        await subscription?.cancel();
        await streamController.close();
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
