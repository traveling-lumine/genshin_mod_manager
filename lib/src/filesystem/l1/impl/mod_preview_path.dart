import '../../l0/api/filesystem.dart';
import '../../l0/api/mod_preview_path.dart';
import '../../l0/entity/mod.dart';
import '../helper.dart';

class ModPreviewPathImpl implements ModPreviewPath {
  factory ModPreviewPathImpl({
    required final Mod mod,
    required final Filesystem fs,
  }) {
    final watcher = fs.watchDirectory(path: mod.path);

    return ModPreviewPathImpl._(
      previewPath: watcher.stream.asyncMap(
        (final event) async {
          final previewName = await findPreviewPath(mod.path);
          return previewName;
        },
      ),
      onDispose: watcher.cancel,
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
