part of '../filesystem_watcher.dart';

FileWatcher createFileWatcher({
  required final String path,
  required final RecursiveFileSystemWatcher watcher,
}) =>
    _FileWatcherImpl(path: path, watcher: watcher);

class _FileWatcherImpl implements FileWatcher {
  _FileWatcherImpl({
    required this.path,
    required this.watcher,
  }) {
    _subscription = watcher.event.stream.where(_shouldUpdate).listen(_listen);
  }

  late final StreamSubscription<FSEvent> _subscription;
  bool _initialized = false;

  final String path;
  final RecursiveFileSystemWatcher watcher;

  @override
  LatestStream<int> get updateCode => vS2LS(_updateCodeStream);
  final _updateCodeStream = BehaviorSubject<int>();

  @override
  void dispose() {
    unawaited(_updateCodeStream.close());
    unawaited(_subscription.cancel());
  }

  bool _shouldUpdate(final FSEvent event) {
    if (!_initialized) {
      _initialized = true;
      return true;
    }
    if (event.force) {
      return true;
    }
    final event2 = event.event!;
    final eventPaths = [event2.path];
    if (event2 is FileSystemMoveEvent && event2.destination != null) {
      eventPaths.add(event2.destination!);
    }
    return eventPaths.any(path.pEquals);
  }

  void _listen(final FSEvent event) {
    _updateCodeStream.add(event.hashCode);
  }
}
