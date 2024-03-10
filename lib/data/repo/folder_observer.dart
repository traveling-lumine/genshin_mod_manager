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
