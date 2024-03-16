part of '../filesystem_watcher.dart';

/// A watcher that watches a directory and its subdirectories.
RecursiveFileSystemWatcher createRecursiveFileSystemWatcher({
  required final String targetPath,
}) =>
    _RecursiveFileSystemWatcherImpl(targetPath: targetPath);

class _RecursiveFileSystemWatcherImpl implements RecursiveFileSystemWatcher {
  _RecursiveFileSystemWatcherImpl({required final String targetPath}) {
    _subscription = Directory(targetPath)
        .watch(recursive: true)
        .map((final event) => FSEvent(event: event))
        .listen(_listen);
  }

  bool _cut = false;
  late final StreamSubscription<FSEvent> _subscription;

  @override
  LatestStream<FSEvent> get event => vS2LS(_subject);
  final _subject = BehaviorSubject<FSEvent>.seeded(const FSEvent(force: true));

  @override
  void dispose() {
    unawaited(_subject.close());
    unawaited(_subscription.cancel());
  }

  @override
  void cut() => _cut = true;

  @override
  void uncut() => _cut = false;

  @override
  void forceUpdate() => _subject.add(const FSEvent(force: true));

  void _listen(final FSEvent event) {
    if (_cut) {
      return;
    }
    _subject.add(event);
  }
}
