import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/latest_stream.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
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
  LatestStream<FileSystemEvent?> get event => vS2LS(_subject.stream);
  final _subject = BehaviorSubject<FileSystemEvent?>.seeded(null);

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
  void forceUpdate() => _subject.add(null);
}

FSEPathsWatcher createCategoryIconWatcher({
  required String targetPath,
}) {
  return _CategoryIconWatcherImpl(
    targetPath: targetPath,
  );
}

class _CategoryIconWatcherImpl implements FSEPathsWatcher {
  late final StreamSubscription<FileSystemEvent?> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_pathsStream.stream);
  final BehaviorSubject<List<String>> _pathsStream;

  _CategoryIconWatcherImpl({
    required String targetPath,
  }) : _pathsStream = BehaviorSubject.seeded(_getPaths(targetPath)) {
    _subscription = Directory(targetPath)
        .watch()
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .listen((event) => _pathsStream.add(_getPaths(targetPath)));
  }

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  static List<String> _getPaths(String targetPath) {
    return List.unmodifiable(getFSEUnder<File>(targetPath).map((e) => e.path));
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
  late final StreamSubscription<FileSystemEvent?> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_paths.stream);
  final BehaviorSubject<List<String>> _paths;

  _FSEPathsWatcherImpl({
    required String targetPath,
    required RecursiveFileSystemWatcher watcher,
  }) : _paths = BehaviorSubject.seeded(_getPaths(targetPath)) {
    _subscription = watcher.event.stream
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .listen((event) => _paths.add(_getPaths(targetPath)));
  }

  @override
  void dispose() {
    _paths.close();
    _subscription.cancel();
  }

  static List<String> _getPaths<T extends FileSystemEntity>(
          String targetPath) =>
      List.unmodifiable(getFSEUnder<T>(targetPath).map((e) => e.path));
}

ModsWatcher createModFoldersWatcher({
  required String targetPath,
  required RecursiveFileSystemWatcher watcher,
}) {
  return _ModFoldersWatcherImpl(
    targetPath: targetPath,
    watcher: watcher,
  );
}

class _ModFoldersWatcherImpl implements ModsWatcher {
  late final StreamSubscription<FileSystemEvent?> _subscription;

  @override
  LatestStream<List<Mod>> get mods => vS2LS(_pathsStream.stream);
  final BehaviorSubject<List<Mod>> _pathsStream;

  _ModFoldersWatcherImpl({
    required String targetPath,
    required RecursiveFileSystemWatcher watcher,
  }) : _pathsStream = BehaviorSubject.seeded(_getPaths(targetPath)) {
    _subscription = watcher.event.stream
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .listen((event) => _pathsStream.add(_getPaths(targetPath)));
  }

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  static List<Mod> _getPaths(String targetPath) {
    return UnmodifiableListView(
      getFSEUnder<Directory>(targetPath)
          .map((e) => Mod(path: e.path))
          .toList(growable: false),
    );
  }
}

bool _ifEventDirectUnder(FileSystemEvent? event, String watchedPath) {
  if (event == null) return true;
  final tgts = [event.path, event.path.pDirname];
  if (event is FileSystemMoveEvent) {
    var destination = event.destination;
    if (destination != null) {
      tgts.add(destination);
      tgts.add(destination.pDirname);
    }
  }
  return tgts
      .any((e) => e.pEquals(watchedPath) | e.pEquals(watchedPath.pDirname));
}
