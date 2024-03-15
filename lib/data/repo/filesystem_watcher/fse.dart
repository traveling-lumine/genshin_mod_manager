part of '../filesystem_watcher.dart';

/// Create a [FSEPathsWatcher] for the given [targetPath]
/// that watches for changes in the file system with type [T].
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
        .where(_shouldUpdate)
        .map(_getPaths)
        .listen(_paths.add);
  }

  static final _logger = Logger();
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

  List<String> _getPaths(final FSEvent event) => getUnderSync<T>(targetPath);

  bool _shouldUpdate(final FSEvent event) {
    if (!_initialized) {
      _initialized = true;
      _logger.t('$this: initialized');
      return true;
    }
    if (event.force) {
      _logger.i('$this: forced update');
      return true;
    }
    final event2 = event.event;
    if (event2 is! FileSystemModifyEvent) {
      _logger.t('$this: event is not a FileSystemModifyEvent');
      return false;
    }
    if (!event2.contentChanged || !event2.isDirectory) {
      _logger.t('$this: event is not a directory content change');
      return false;
    }
    final path = event2.path;
    final pEquals = targetPath.pEquals(path);
    if (pEquals) {
      _logger.i('$this: accepted event');
    }
    return pEquals;
  }

  @override
  String toString() =>
      'FSEPathsWatcher($targetPath)[initialized: $_initialized]';
}
