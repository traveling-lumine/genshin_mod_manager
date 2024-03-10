import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/domain/repo/fs_watch.dart';
import 'package:genshin_mod_manager/domain/repo/proxy_fs_watcher.dart';
import 'package:rxdart/rxdart.dart';

FileSystemWatcher createFileSystemWatchService({
  required String targetPath,
}) {
  return _FileSystemWatchServiceImpl(targetPath: targetPath);
}

class _FileSystemWatchServiceImpl implements FileSystemWatcher {
  @override
  // TODO: implement event
  Stream<FileSystemEvent?> get event => throw UnimplementedError();

  _FileSystemWatchServiceImpl({
    required String targetPath,
  }) {
    final stream = Directory(targetPath).watch(recursive: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

RecursiveFileSystemWatcher createRecursiveFileSystemWatchService({
  required String targetPath,
}) {
  return _RecursiveFSWatchServiceImpl(targetPath: targetPath);
}

class _RecursiveFSWatchServiceImpl implements RecursiveFileSystemWatcher {
  final StreamController<FileSystemEvent?> _streamController =
      StreamController.broadcast();
  late final StreamSubscription<FileSystemEvent> _subscription;
  bool _isCut = false;

  _RecursiveFSWatchServiceImpl({
    required String targetPath,
  }) {
    final stream = Directory(targetPath).watch(recursive: true);
    forceUpdate();
    _subscription = stream.listen(
      (event) {
        if (_isCut) return;
        _streamController.add(event);
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    _subscription.cancel();
  }

  @override
  Stream<FileSystemEvent?> get event => _streamController.stream;

  @override
  void cut() => _isCut = true;

  @override
  void uncut() => _isCut = false;

  @override
  void forceUpdate() => _streamController.add(null);
}

ProxyFileSystemWatcher<T>
    createRelayFSEWatchService<T extends FileSystemEntity>({
  required RecursiveFileSystemWatcher host,
  required String targetPath,
}) {
  return _ProxyFileSystemWatcherImpl<T>(
    host: host,
    targetPath: targetPath,
  );
}

class _ProxyFileSystemWatcherImpl<T extends FileSystemEntity>
    implements ProxyFileSystemWatcher<T> {
  @override
  Stream<List<T>> get entity => _entityStream.stream;
  final BehaviorSubject<List<T>> _entityStream;

  _ProxyFileSystemWatcherImpl({
    required RecursiveFileSystemWatcher host,
    required String targetPath,
  }) : _entityStream = BehaviorSubject.seeded(getFSEUnder<T>(targetPath)) {
    _createStream(targetPath, host).pipe(_entityStream);
  }

  Stream<List<T>> _createStream(
    String targetPath,
    RecursiveFileSystemWatcher host,
  ) async* {
    yield getFSEUnder<T>(targetPath);
    await for (var event in host.event) {
      if (!_ifEventDirectUnder(event, targetPath)) continue;
      final fseUnder = getFSEUnder<T>(targetPath);
      yield fseUnder;
    }
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
