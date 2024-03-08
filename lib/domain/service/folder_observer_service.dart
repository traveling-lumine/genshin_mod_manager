import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';

abstract class _StreamObserverService extends ChangeNotifier {
  final String targetPath;
  late StreamSubscription<FileSystemEvent> _subscription;

  _StreamObserverService({required this.targetPath, required bool recursive}) {
    final stream = Directory(targetPath).watch(recursive: recursive);
    _subscription = stream.listen(listener);
  }

  void listener(FileSystemEvent event);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class CategoryIconFolderObserverService extends _StreamObserverService {
  List<File> _curFiles;

  List<File> get curFiles => UnmodifiableListView(_curFiles);

  CategoryIconFolderObserverService({required super.targetPath})
      : _curFiles = getFSEUnder<File>(targetPath),
        super(recursive: false);

  @override
  void listener(FileSystemEvent event) {
    _curFiles = getFSEUnder<File>(targetPath);
    notifyListeners();
  }
}

class RecursiveObserverService extends _StreamObserverService {
  bool _cut = false;
  FileSystemEvent? _lastEvent;

  FileSystemEvent? get lastEvent => _lastEvent;

  RecursiveObserverService({required super.targetPath})
      : super(recursive: true);

  @override
  void listener(FileSystemEvent? event) {
    if (_cut) return;
    _lastEvent = event;
    notifyListeners();
  }

  void cut() => _cut = true;

  void uncut() => _cut = false;

  void forceUpdate() => listener(null);
}

class RootWatchService with ChangeNotifier {
  final _listEquality = const ListEquality();
  final String targetPath;
  List<String> _categories = [];

  List<String> get categories => _categories;

  RootWatchService({required this.targetPath}) {
    _getDirs();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetPath)) return;
    final isEqual = _getDirs();
    if (isEqual) return;
    notifyListeners();
  }

  bool _getDirs() {
    final before = _categories;
    try {
      _categories = getFSEUnder<Directory>(targetPath)
          .map((e) => e.path.pBasename)
          .toList(growable: false)
        ..sort(compareNatural);
    } on PathNotFoundException {
      _categories = [];
    }
    return _listEquality.equals(before, _categories);
  }
}

class FSEWatchService<T extends FileSystemEntity> extends ChangeNotifier {
  final String targetPath;

  late List<T> _curEntities;

  List<T> get curEntities => _curEntities;

  FSEWatchService({required this.targetPath}) {
    _getEntities();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetPath)) return;
    _getEntities();
    notifyListeners();
  }

  void _getEntities() {
    try {
      _curEntities = getFSEUnder<T>(targetPath);
    } on PathNotFoundException {
      _curEntities = [];
    }
  }
}

class DirWatchService extends FSEWatchService<Directory> {
  DirWatchService({required super.targetPath});
}

class FileWatchService extends FSEWatchService<File> {
  FileWatchService({required super.targetPath});
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
