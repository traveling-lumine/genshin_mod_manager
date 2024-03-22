import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/provider/app_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_shell.g.dart';

class RootWatcher {
  RootWatcher(final String modRoot)
      : _dir = Directory(modRoot),
        _iconDir = Directory(
            Platform.resolvedExecutable.pDirname.pJoin(_resourceDir)) {
    _iconDir.createSync(recursive: true);
    final icons = getUnderSync<File>(_iconDir.path);
    final categories2 = getUnderSync<Directory>(_dir.path);
    final res = categories2.map((final event) {
      final name = event.pBasename;
      return ModCategory(
        path: event,
        name: name,
        iconPath: findPreviewFileInString(icons, name: name),
      );
    }).toList();
    _controller.add(res);
    _subscription = _dir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .listen(_listen);
    _subscription2 = _iconDir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .listen(_listen);
  }

  static const _resourceDir = 'Resources';

  final StreamController<List<ModCategory>> _controller =
      StreamController<List<ModCategory>>();
  final Directory _dir;
  final Directory _iconDir;
  late final StreamSubscription<FileSystemEvent> _subscription;
  late final StreamSubscription<FileSystemEvent> _subscription2;

  Stream<List<ModCategory>> get categories => _controller.stream;

  void dispose() {
    unawaited(_subscription2.cancel());
    unawaited(_subscription.cancel());
    unawaited(_controller.close());
  }

  void _listen(final FileSystemEvent event) {
    final icons = getUnderSync<File>(_iconDir.path);
    final categories2 = getUnderSync<Directory>(_dir.path);
    final res = categories2.map((final event) {
      final name = event.pBasename;
      return ModCategory(
        path: event,
        name: name,
        iconPath: findPreviewFileInString(icons, name: name),
      );
    }).toList();
    _controller.add(res);
  }
}

@riverpod
Stream<List<ModCategory>> homeShellNotifier(final HomeShellNotifierRef ref) {
  final modRoot = ref
      .watch(appStateNotifierProvider.select((final state) => state.modRoot));
  final watcher = RootWatcher(modRoot!);
  ref.onDispose(watcher.dispose);
  return watcher.categories;
}
