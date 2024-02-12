import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';

class CategoryIconFolderObserverService with ChangeNotifier {
  final String targetPath;
  late StreamSubscription<FileSystemEvent> _subscription;

  List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  CategoryIconFolderObserverService({required this.targetPath})
      : _curFiles = getFilesUnder(targetPath) {
    _subscription = Directory(targetPath).watch().listen((event) {
      _curFiles = getFilesUnder(targetPath);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class RecursiveObserverService with ChangeNotifier {
  final String targetPath;
  late StreamSubscription<FileSystemEvent> _subscription;

  FileSystemEvent? _lastEvent;

  FileSystemEvent? get lastEvent => _lastEvent;

  RecursiveObserverService({required this.targetPath}) {
    _subscription =
        Directory(targetPath).watch(recursive: true).listen((event) {
      _lastEvent = event;
      notifyListeners();
    });
  }

  void forceUpdate() {
    _lastEvent = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
      _categories = getDirsUnder(targetPath)
          .map((e) => e.path.pBasename)
          .toList(growable: false)
        ..sort(compareNatural);
    } on PathNotFoundException {
      _categories = [];
    }
    return _listEquality.equals(before, _categories);
  }
}

class DirWatchService with ChangeNotifier {
  final String targetPath;

  late List<Directory> _curDirs;

  List<Directory> get curDirs => _curDirs;

  DirWatchService({required this.targetPath}) {
    _getDirs();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetPath)) return;
    _getDirs();
    notifyListeners();
  }

  void _getDirs() {
    try {
      _curDirs = getDirsUnder(targetPath);
    } on PathNotFoundException {
      _curDirs = [];
    }
  }
}

class FileWatchService with ChangeNotifier {
  final String targetPath;

  late List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  FileWatchService({required this.targetPath}) {
    _getFiles();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetPath)) return;
    _getFiles();
    notifyListeners();
  }

  void _getFiles() {
    try {
      _curFiles = getFilesUnder(targetPath);
    } on PathNotFoundException {
      _curFiles = [];
    }
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
  return tgts.any((e) => e.pEquals(watchedPath));
}
