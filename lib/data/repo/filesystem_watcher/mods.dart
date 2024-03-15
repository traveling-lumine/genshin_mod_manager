part of '../filesystem_watcher.dart';

ModsWatcher createModsWatcher({
  required final ModCategory category,
  required final RecursiveFileSystemWatcher watcher,
}) =>
    _ModsWatcherImpl(
      category: category,
      watcher: watcher,
    );

class _ModsWatcherImpl implements ModsWatcher {
  _ModsWatcherImpl({
    required this.category,
    required final RecursiveFileSystemWatcher watcher,
  }) {
    _subscription = watcher.event.stream.asyncMap(_getMods).listen(_listen);
  }

  static final _logger = Logger();
  final ModCategory category;
  late final StreamSubscription<List<Mod>> _subscription;

  @override
  LatestStream<List<Mod>> get mods => vS2LS(_pathsStream);
  final _pathsStream = BehaviorSubject<List<Mod>>();

  @override
  void dispose() {
    _pathsStream.close();
    _subscription.cancel();
  }

  Future<List<Mod>> _getMods(final FSEvent _) => getMods(category);

  void _listen(final List<Mod> event) {
    _logger.d('$this: updated');
    _pathsStream.add(event);
  }

  @override
  String toString() => '_ModsWatcherImpl($category)';
}
