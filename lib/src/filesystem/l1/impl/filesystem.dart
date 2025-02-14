import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/filesystem.dart';
import '../../l0/api/watcher.dart';
import 'watcher.dart';

class FilesystemImpl implements Filesystem {
  bool _isPaused = false;
  final Map<
      String,
      (
        StreamController<FileSystemEvent?>,
        StreamSubscription<FileSystemEvent>,
        int
      )> _watchStream = {};

  Stream<FileSystemEvent?> _getSwitchStream(final String path) {
    // check path is dir
    if (!Directory(path).existsSync()) {
      throw FileSystemException('Directory does not exist', path);
    }

    final stream = _watchStream[path];
    if (stream != null) {
      _watchStream[path] = (stream.$1, stream.$2, stream.$3 + 1);
      return stream.$1.stream;
    }

    // these streams will be closed when the path is released
    // ignore: close_sinks
    final controller = BehaviorSubject<FileSystemEvent?>.seeded(null);

    final streamForSubscription = _isPaused
        ? const Stream<FileSystemEvent>.empty()
        : Directory(path).watch();
    // see above
    // ignore: cancel_subscriptions
    final subscription = streamForSubscription.listen(controller.add);
    _watchStream[path] = (controller, subscription, 1);
    return controller.stream;
  }

  Future<void> _releaseSwitchStream(final String path) async {
    final stream = _watchStream[path];
    if (stream == null) {
      return;
    }
    if (stream.$3 == 1) {
      await Future.wait([stream.$2.cancel(), stream.$1.close()]);
      _watchStream.remove(path);
    } else {
      _watchStream[path] = (stream.$1, stream.$2, stream.$3 - 1);
    }
  }

  @override
  Future<void> pauseAllWatchers() async {
    if (_isPaused) {
      return;
    }
    _isPaused = true;

    await Future.wait(
      _watchStream.values.map((final stream) async => stream.$2.cancel()),
    );
  }

  @override
  void resumeAllWatchers() {
    if (!_isPaused) {
      return;
    }
    _isPaused = false;

    for (final path in _watchStream.keys) {
      final stream = _watchStream[path];
      if (stream == null) {
        continue;
      }
      stream.$1.add(null); // send null to indicate that the stream is resumed
      if (Directory(path).existsSync()) {
        _watchStream[path] = (
          stream.$1,
          Directory(path).watch().listen(stream.$1.add),
          stream.$3
        );
      }
    }
  }

  @override
  Future<void> dispose() async {
    await Future.wait<Object?>([
      for (final path in _watchStream.values) ...[
        path.$2.cancel(),
        path.$1.close(),
      ],
    ]);
  }

  @override
  Watcher watchDirectory({
    required final String path,
  }) {
    if (!Directory(path).existsSync()) {
      return FSSubscription(
        stream: Stream.value(null),
        onCancel: () async {},
      );
    }
    final stream = _getSwitchStream(path);

    return FSSubscription(
      stream: stream,
      onCancel: () async => _releaseSwitchStream(path),
    );
  }

  @override
  Watcher watchFile({
    required final String path,
  }) {
    if (!File(path).existsSync()) {
      return FSSubscription(
        stream: Stream.value(null),
        onCancel: () async {},
      );
    }
    final dirPath = File(path).parent.path;
    final stream = _getSwitchStream(dirPath);

    return FSSubscription(
      stream: stream.where(
        (final event) {
          if (event == null) {
            return true;
          }
          if (event is FileSystemMoveEvent) {
            return p.equals(event.destination ?? '', path);
          }
          return p.equals(event.path, path);
        },
      ),
      onCancel: () async => _releaseSwitchStream(dirPath),
    );
  }
}
