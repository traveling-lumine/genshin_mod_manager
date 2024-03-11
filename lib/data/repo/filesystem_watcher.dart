import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/util.dart';
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

FSEntityWatcher<T> createFSEntityWatcher<T extends FileSystemEntity>({
  required String targetPath,
}) {
  return _FSEntityWatcherImpl<T>(
    targetPath: targetPath,
  );
}

class _FSEntityWatcherImpl<T extends FileSystemEntity>
    implements FSEntityWatcher<T> {
  late final StreamSubscription<FileSystemEvent> _subscription;

  @override
  LatestStream<List<T>> get entity => vS2LS(_entityStream.stream);
  final BehaviorSubject<List<T>> _entityStream;

  _FSEntityWatcherImpl({
    required String targetPath,
  }) : _entityStream = BehaviorSubject.seeded(getFSEUnder<T>(targetPath)) {
    _subscription = Directory(targetPath)
        .watch(recursive: false)
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .listen((event) => _entityStream.add(getFSEUnder<T>(targetPath)));
  }

  @override
  void dispose() {
    _entityStream.close();
    _subscription.cancel();
  }
}

FSEntityWatcher<T> createProxyFSEntityWatcher<T extends FileSystemEntity>({
  required String targetPath,
  required RecursiveFileSystemWatcher watcher,
}) {
  return _ProxyFSEntityWatcherImpl<T>(
    targetPath: targetPath,
    watcher: watcher,
  );
}

class _ProxyFSEntityWatcherImpl<T extends FileSystemEntity>
    implements FSEntityWatcher<T> {
  late final StreamSubscription<FileSystemEvent?> _subscription;

  @override
  LatestStream<List<T>> get entity => vS2LS(_entityStream.stream);
  final BehaviorSubject<List<T>> _entityStream;

  _ProxyFSEntityWatcherImpl({
    required String targetPath,
    required RecursiveFileSystemWatcher watcher,
  }) : _entityStream = BehaviorSubject.seeded(getFSEUnder<T>(targetPath)) {
    _subscription = watcher.event.stream
        .where((event) => _ifEventDirectUnder(event, targetPath))
        .listen((event) => _entityStream.add(getFSEUnder<T>(targetPath)));
  }

  @override
  void dispose() {
    _entityStream.close();
    _subscription.cancel();
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
