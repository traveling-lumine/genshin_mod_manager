import 'dart:async';

import '../../l0/api/mod_preview_path.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod.dart';
import '../helper.dart';

class ModPreviewPathImpl implements ModPreviewPath {
  factory ModPreviewPathImpl({
    required final Mod mod,
    required final Watcher watcher,
  }) {
    final streamController = StreamController<String?>();
    StreamSubscription<String?>? streamSubscription;

    unawaited(
      findPreviewPath(mod.path).then<void>((final value) {
        if (streamController.isClosed) {
          return;
        }
        streamController.add(value);
        streamSubscription = watcher.stream
            .asyncMap((final event) => findPreviewPath(mod.path))
            .distinct()
            .listen(
              streamController.add,
              onError: streamController.addError,
              onDone: streamController.close,
            );
      }).catchError(streamController.addError),
    );

    return ModPreviewPathImpl._(
      previewPath: streamController.stream,
      onDispose: () async {
        await streamSubscription?.cancel();
        await streamController.close();
      },
    );
  }

  const ModPreviewPathImpl._({
    required this.previewPath,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<String?> previewPath;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }
}
