import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem.dart';

FSWatchService createFileSystemWatchService({
  required String targetPath,
}) {
  return _FileSystemWatchServiceImpl(targetPath: targetPath);
}

class _FileSystemWatchServiceImpl implements FSWatchService {
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

RecursiveFSWatchService createRecursiveFileSystemWatchService({
  required String targetPath,
}) {
  return _RecursiveFSWatchServiceImpl(targetPath: targetPath);
}

class _RecursiveFSWatchServiceImpl implements RecursiveFSWatchService {
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

RelayFSEWatchService<T> createRelayFSEWatchService<T extends FileSystemEntity>({
  required RecursiveFSWatchService host,
  required String targetPath,
}) {
  return RelayFSEWatchServiceImpl<T>(
    host: host,
    targetPath: targetPath,
  );
}

class RelayFSEWatchServiceImpl<T extends FileSystemEntity>
    extends ChangeNotifier implements RelayFSEWatchService<T> {
  late StreamSubscription<FileSystemEvent?> _subscription;

  @override
  List<T> get entities => UnmodifiableListView(_entities);
  List<T> _entities;

  RelayFSEWatchServiceImpl({
    required RecursiveFSWatchService host,
    required String targetPath,
  }) : _entities = getFSEUnder<T>(targetPath) {
    _subscription = host.event.listen((event) {
      if (!_ifEventDirectUnder(event, targetPath)) return;
      _entities = getFSEUnder<T>(targetPath);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
