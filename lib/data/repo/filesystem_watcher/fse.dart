part of '../filesystem_watcher.dart';

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
        .where((final event) => _ifEventDirectUnder2(event, targetPath))
        .map(_getPaths)
        .listen(_paths.add);
  }

  bool _initialized = false;

  String targetPath;

  StreamSubscription<List<String>>? _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_paths);
  final _paths = BehaviorSubject<List<String>>();

  @override
  void dispose() {
    unawaited(_paths.close());
    unawaited(_subscription?.cancel());
  }

  List<String> _getPaths(
    final FSEvent event,
  ) =>
      getUnderSync<T>(targetPath);

  bool _ifEventDirectUnder2(
    final FSEvent event,
    final String watchedPath,
  ) {
    if (!_initialized) {
      _initialized = true;
      return true;
    }
    if (event.force) {
      return true;
    }
    final paths = event.paths;
    final targets = paths.map((final e) => e.pDirname).toList() + paths;
    return targets.any(
      (final e) => e.pEquals(watchedPath) | e.pEquals(watchedPath.pDirname),
    );
  }
}
