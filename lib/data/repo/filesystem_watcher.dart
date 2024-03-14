import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/mapper/latest_stream.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/rxdart.dart';

RecursiveFileSystemWatcher createRecursiveFileSystemWatcher({
  required final String targetPath,
}) =>
    _RecursiveFileSystemWatcherImpl(targetPath: targetPath);

class _RecursiveFileSystemWatcherImpl implements RecursiveFileSystemWatcher {
  _RecursiveFileSystemWatcherImpl({required final String targetPath}) {
    _subscription =
        Directory(targetPath).watch(recursive: true).listen(_subject.add);
  }

  late final StreamSubscription<FileSystemEvent> _subscription;

  @override
  LatestStream<FileSystemEvent> get event => vS2LS(_subject.stream);
  final _subject = BehaviorSubject<FileSystemEvent>();

  @override
  void dispose() {
    unawaited(_subject.close());
    unawaited(_subscription.cancel());
  }

  @override
  void cut() => _subscription.pause();

  @override
  void uncut() => _subscription.resume();

  @override
  void forceUpdate() => throw UnimplementedError();
}

FSEPathsWatcher createCategoryIconWatcher({
  required final String targetPath,
}) =>
    _CategoryIconWatcherImpl(
      targetPath: targetPath,
    );

class _CategoryIconWatcherImpl implements FSEPathsWatcher {
  _CategoryIconWatcherImpl({
    required final String targetPath,
  }) {
    _subscription = Directory(targetPath)
        .watch()
        .where((final event) => _ifEventDirectUnder(event, targetPath))
        .asyncMap((final event) => _getPaths(targetPath))
        .listen(_pathsStream.add);
  }

  late final StreamSubscription<List<String>> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_pathsStream.stream);
  final _pathsStream = BehaviorSubject<List<String>>();

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  static Future<List<String>> _getPaths(final String targetPath) async =>
      List.unmodifiable(
        (await getUnder<File>(targetPath)).map((final e) => e.path),
      );
}

FSEPathsWatcher createFSEPathsWatcher<T extends FileSystemEntity>({
  required final String targetPath,
  required final RecursiveFileSystemWatcher watcher,
}) =>
    _FSEPathsWatcherImpl<T>(
      targetPath: targetPath,
      watcher: watcher,
    );

class _FSEPathsWatcherImpl<T extends FileSystemEntity>
    implements FSEPathsWatcher {

  _FSEPathsWatcherImpl({
    required this.targetPath,
    required final RecursiveFileSystemWatcher watcher,
  }) {
    _subscription = watcher.event.stream
        .where((final event) => _ifEventDirectUnder(event, targetPath))
        .asyncMap(_getPaths)
        .listen(_paths.add);
  }
  String targetPath;

  late final StreamSubscription<List<String>> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_paths.stream);
  final BehaviorSubject<List<String>> _paths = BehaviorSubject<List<String>>();

  @override
  void dispose() {
    unawaited(_paths.close());
    unawaited(_subscription.cancel());
  }

  Future<List<String>> _getPaths(
    final FileSystemEvent event,
  ) async =>
      List.unmodifiable(
        (await getUnder<T>(targetPath)).map((final e) => e.path),
      );
}

ModsWatcher createModsWatcher({
  required final ModCategory category,
  required final RecursiveFileSystemWatcher watcher,
}) =>
    _ModsWatcherImpl(
      category: category,
      watcher: watcher,
    );

class _ModsWatcherImpl implements ModsWatcher {
  _ModsWatcherImpl({
    required this.category,
    required final RecursiveFileSystemWatcher watcher,
  }) {
    _subscription = watcher.event.stream
        .where(_shouldTake)
        .asyncMap(_getMods)
        .listen(_pathsStream.add);
  }

  final ModCategory category;

  late final StreamSubscription<List<Mod>> _subscription;

  @override
  LatestStream<List<Mod>> get mods => vS2LS(_pathsStream.stream);
  final _pathsStream = BehaviorSubject<List<Mod>>();

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  Future<List<Mod>> _getMods(final FileSystemEvent _) => getMods(category);

  bool _shouldTake(final FileSystemEvent event) => true;
}

bool _ifEventDirectUnder(
  final FileSystemEvent event,
  final String watchedPath,
) {
  // if (event == null) return true;
  final targets = [event.path, event.path.pDirname];
  if (event is FileSystemMoveEvent) {
    final destination = event.destination;
    if (destination != null) {
      targets
        ..add(destination)
        ..add(destination.pDirname);
    }
  }
  return targets.any(
    (final e) => e.pEquals(watchedPath) | e.pEquals(watchedPath.pDirname),
  );
}
