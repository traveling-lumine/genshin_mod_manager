import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/fs_watcher.dart';

class FolderWatcher<T extends FileSystemEntity> {
  FolderWatcher({
    required this.path,
    final bool watchModifications = false,
    final bool broadcast = false,
  }) : _controller = broadcast
            ? StreamController<List<String>>.broadcast()
            : StreamController<List<String>>() {
    _add(null);
    var events =
        FileSystemEvent.delete | FileSystemEvent.create | FileSystemEvent.move;
    if (watchModifications) {
      events |= FileSystemEvent.modify;
    }
    _subscription = Directory(path).watch(events: events).listen(_add);
  }

  final String path;
  final StreamController<List<String>> _controller;
  late final StreamSubscription<FileSystemEvent> _subscription;

  Stream<List<String>> get entities => _controller.stream;

  void _add(final FileSystemEvent? event) {
    final files = getUnderSync<T>(path);
    _controller.add(files);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}

class FileModificationWatcher {
  FileModificationWatcher({
    required final String path,
    required final FolderWatcher<File> watcher,
  })  : _path = path,
        assert(FileSystemEntity.isFileSync(path), 'Should be a file'),
        assert(watcher.path == path.pDirname, 'Should be the same directory') {
    _updateMTime();
    _subscription = watcher.entities.listen(_listen);
  }

  final String _path;
  final _controller = StreamController<int>();
  late final StreamSubscription<List<String>> _subscription;

  Stream<int> get eventTime => _controller.stream;

  void _listen(final List<String> event) {
    final isIn = event.contains(_path);
    if (!isIn) {
      return;
    }
    _updateMTime();
  }

  void _updateMTime() {
    _controller.add(File(_path).lastModifiedSync().millisecondsSinceEpoch);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}

class CategoryModel implements CategoryWatcher {
  CategoryModel({
    required final bool enabledFirst,
    required final ModCategory category,
  })  : _enabledFirst = enabledFirst,
        _category = category,
        _watcher = FolderWatcher<Directory>(path: category.path);

  final bool _enabledFirst;
  final ModCategory _category;
  final FolderWatcher<Directory> _watcher;

  @override
  late Stream<List<Mod>> mods = _watcher.entities.map(_add);

  @override
  Future<void> dispose() async {
    await _watcher.dispose();
  }

  List<Mod> _add(final List<String> event) =>
      event.map(_converter).toList()..sort(_sort);

  Mod _converter(final String path) => Mod(
        path: path,
        displayName: path.pEnabledForm.pBasename,
        isEnabled: path.pIsEnabled,
        category: _category,
      );

  int _sort(final Mod a, final Mod b) {
    if (_enabledFirst) {
      final aEnabled = a.isEnabled;
      final bEnabled = b.isEnabled;
      if (aEnabled && !bEnabled) {
        return -1;
      } else if (!aEnabled && bEnabled) {
        return 1;
      }
    }
    final aLower = a.path.pEnabledForm.pBasename.toLowerCase();
    final bLower = b.path.pEnabledForm.pBasename.toLowerCase();
    return aLower.compareTo(bLower);
  }
}

class RootWatcherImpl implements RootWatcher {
  RootWatcherImpl(final String modRoot) : _dir = Directory(modRoot) {
    _add();
    _subscription = _dir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .listen(_listen);
  }

  final StreamController<List<ModCategory>> _controller =
      StreamController<List<ModCategory>>();
  final Directory _dir;
  late final StreamSubscription<FileSystemEvent> _subscription;

  @override
  Stream<List<ModCategory>> get categories => _controller.stream.distinct(
        (final previous, final next) =>
            const ListEquality<ModCategory>().equals(previous, next),
      );

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_controller.close());
  }

  void _listen(final FileSystemEvent event) {
    _add();
  }

  void _add() {
    final categories2 = getUnderSync<Directory>(_dir.path);
    final res = categories2.map((final event) {
      final name = event.pBasename;
      return ModCategory(
        path: event,
        name: name,
      );
    }).toList();
    _controller.add(res);
  }

  @override
  void refresh() {
    _add();
  }
}
