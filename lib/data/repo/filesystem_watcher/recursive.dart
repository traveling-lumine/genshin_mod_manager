part of '../filesystem_watcher.dart';

RecursiveFileSystemWatcher createRecursiveFileSystemWatcher({
  required final String targetPath,
}) =>
    _RecursiveFileSystemWatcherImpl(targetPath: targetPath);

class _RecursiveFileSystemWatcherImpl implements RecursiveFileSystemWatcher {
  _RecursiveFileSystemWatcherImpl({required final String targetPath}) {
    _subscription =
        Directory(targetPath).watch(recursive: true).map((final event) {
      final paths = <String>[];
      if (event is FileSystemMoveEvent && event.destination != null) {
        paths.add(event.destination!);
      }
      paths.add(event.path);
      return FSEvent(paths: paths);
    }).listen(_subject.add);
  }

  late final StreamSubscription<FSEvent> _subscription;

  @override
  LatestStream<FSEvent> get event => vS2LS(_subject);
  final _subject = BehaviorSubject<FSEvent>.seeded(
    const FSEvent(paths: [], force: true),
  );

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
  void forceUpdate() => _subject.add(const FSEvent(paths: [], force: true));
}
