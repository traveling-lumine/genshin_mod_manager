import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';

class CategoryIconFolderObserverService with ChangeNotifier {
  final Directory targetDir;
  late StreamSubscription<FileSystemEvent> _subscription;

  List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  CategoryIconFolderObserverService({required this.targetDir})
      : _curFiles = getFilesUnder(targetDir) {
    _subscription = targetDir.watch().listen((event) {
      _curFiles = getFilesUnder(targetDir);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ModRecursiveObserverService with ChangeNotifier {
  final Directory targetDir;
  late StreamSubscription<FileSystemEvent> _subscription;

  FileSystemEvent? _lastEvent;

  FileSystemEvent? get lastEvent => _lastEvent;

  ModRecursiveObserverService({required this.targetDir}) {
    _subscription = targetDir.watch(recursive: true).listen((event) {
      _lastEvent = event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ModsObserverService with ChangeNotifier {
  final Directory targetDir;

  List<Directory> _curDirs;

  List<Directory> get curDirs => _curDirs;

  ModsObserverService({required this.targetDir})
      : _curDirs = getDirsUnder(targetDir);

  void update(FileSystemEvent? event) {
    if (!_shouldUpdate(event)) return;
    _curDirs = getDirsUnder(targetDir);
    notifyListeners();
  }

  bool _shouldUpdate(FileSystemEvent? event) {
    if (event == null) return true;
    return PathW(event.path).dirname == targetDir.pathW;
  }
}
