import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/latest_stream.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/rxdart.dart';

RecursiveFileSystemWatcher createRecursiveFileSystemWatcher({
  required String targetPath,
}) {
  return _RecursiveFileSystemWatcherImpl(targetPath: targetPath);
}

class _RecursiveFileSystemWatcherImpl implements RecursiveFileSystemWatcher {
  late final StreamSubscription<FileSystemEvent> _subscription;

  @override
  LatestStream<FileSystemEvent> get event => vS2LS(_subject.stream);
  final _subject = BehaviorSubject<FileSystemEvent>();

  _RecursiveFileSystemWatcherImpl({required String targetPath}) {
    _subscription =
        Directory(targetPath).watch(recursive: true).listen(_subject.add);
  }

  @override
  void dispose() {
    _subject.close();
    _subscription.cancel();
  }

  @override
  void cut() => _subscription.pause();

  @override
  void uncut() => _subscription.resume();

  @override
  void forceUpdate() => throw UnimplementedError();
}

FSEPathsWatcher createCategoryIconWatcher({
  required String targetPath,
}) {
  return _CategoryIconWatcherImpl(
    targetPath: targetPath,
  );
}

class _CategoryIconWatcherImpl implements FSEPathsWatcher {
  late final StreamSubscription<List<String>> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_pathsStream.stream);
  final _pathsStream = BehaviorSubject<List<String>>();

  _CategoryIconWatcherImpl({
    required String targetPath,
  }) {
    _subscription = Directory(targetPath)
        .watch()
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .asyncMap((event) => _getPaths(targetPath))
        .listen((event) => _pathsStream.add(event));
  }

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  static Future<List<String>> _getPaths(String targetPath) async {
    return List.unmodifiable(
        (await getFSEUnder<File>(targetPath)).map((e) => e.path));
  }
}

FSEPathsWatcher createFSEPathsWatcher<T extends FileSystemEntity>({
  required String targetPath,
  required RecursiveFileSystemWatcher watcher,
}) {
  return _FSEPathsWatcherImpl<T>(
    targetPath: targetPath,
    watcher: watcher,
  );
}

class _FSEPathsWatcherImpl<T extends FileSystemEntity>
    implements FSEPathsWatcher {
  late final StreamSubscription<List<String>> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_paths.stream);
  final BehaviorSubject<List<String>> _paths = BehaviorSubject<List<String>>();

  _FSEPathsWatcherImpl({
    required String targetPath,
    required RecursiveFileSystemWatcher watcher,
  }) {
    _subscription = watcher.event.stream
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .asyncMap((event) => _getPaths(targetPath))
        .listen((event) => _paths.add(event));
  }

  @override
  void dispose() {
    _paths.close();
    _subscription.cancel();
  }

  static Future<List<String>> _getPaths<T extends FileSystemEntity>(
          String targetPath) async =>
      List.unmodifiable((await getFSEUnder<T>(targetPath)).map((e) => e.path));
}

ModsWatcher createModsWatcher({
  required ModCategory category,
  required RecursiveFileSystemWatcher watcher,
}) {
  return _ModsWatcherImpl(
    category: category,
    watcher: watcher,
  );
}

class _ModsWatcherImpl implements ModsWatcher {
  final ModCategory category;

  late final StreamSubscription<List<Mod>> _subscription;

  @override
  LatestStream<List<Mod>> get mods => vS2LS(_pathsStream.stream);
  final _pathsStream = BehaviorSubject<List<Mod>>();

  _ModsWatcherImpl({
    required this.category,
    required RecursiveFileSystemWatcher watcher,
  }) {
    _subscription = watcher.event.stream
        .where(_shouldTake)
        .asyncMap(_getMods)
        .listen((event) => _pathsStream.add(event));
  }

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  Future<List<Mod>> _getMods(FileSystemEvent _) async {
    return await getMods(category);
  }

  bool _shouldTake(FileSystemEvent event) {
    return true;
  }
}

bool _ifEventDirectUnder(FileSystemEvent event, String watchedPath) {
  // if (event == null) return true;
  final tgts = [event.path, event.path.pDirname];
  if (event is FileSystemMoveEvent) {
    final destination = event.destination;
    if (destination != null) {
      tgts.add(destination);
      tgts.add(destination.pDirname);
    }
  }
  return tgts
      .any((e) => e.pEquals(watchedPath) | e.pEquals(watchedPath.pDirname));
}
