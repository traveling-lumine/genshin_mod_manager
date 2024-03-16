part of '../filesystem_watcher.dart';

/// A watcher for category icons.
FSEPathsWatcher createCategoryIconWatcher({
  required final String targetPath,
}) =>
    _CategoryIconWatcherImpl(
      targetPath: targetPath,
    );

class _CategoryIconWatcherImpl implements FSEPathsWatcher {
  _CategoryIconWatcherImpl({
    required this.targetPath,
  }) {
    _pathsStream.add(_getPaths());
    _subscription = Directory(targetPath)
        .watch()
        .map((final event) => _getPaths())
        .listen(_pathsStream.add);
  }

  final String targetPath;
  late final StreamSubscription<List<String>> _subscription;

  @override
  LatestStream<List<String>> get paths => vS2LS(_pathsStream);
  final _pathsStream = BehaviorSubject<List<String>>();

  @override
  void dispose() {
    unawaited(_pathsStream.close());
    unawaited(_subscription.cancel());
  }

  List<String> _getPaths() => getUnder<File>(targetPath);
}
