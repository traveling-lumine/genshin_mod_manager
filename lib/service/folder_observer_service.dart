import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:provider/provider.dart';

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

class RecursiveObserverService with ChangeNotifier {
  final Directory targetDir;
  late StreamSubscription<FileSystemEvent> _subscription;

  FileSystemEvent? _lastEvent;

  FileSystemEvent? get lastEvent => _lastEvent;

  RecursiveObserverService({required this.targetDir}) {
    _subscription = targetDir.watch(recursive: true).listen((event) {
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

class DirWatchService with ChangeNotifier {
  final Directory targetDir;

  late List<Directory> _curDirs;

  List<Directory> get curDirs => _curDirs;

  DirWatchService({required this.targetDir}) {
    _getDirs();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetDir)) return;
    _getDirs();
    notifyListeners();
  }

  void _getDirs() {
    try {
      _curDirs = getDirsUnder(targetDir);
    } on PathNotFoundException {
      _curDirs = [];
    }
  }
}

class FileWatchService with ChangeNotifier {
  final Directory targetDir;

  late List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  FileWatchService({required this.targetDir}) {
    _getFiles();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetDir)) return;
    _getFiles();
    notifyListeners();
  }

  void _getFiles() {
    try {
      _curFiles = getFilesUnder(targetDir);
    } on PathNotFoundException {
      _curFiles = [];
    }
  }
}

class DirWatchProvider extends StatelessWidget {
  final Directory dir;
  final Widget child;

  const DirWatchProvider({
    super.key,
    required this.dir,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        DirWatchService>(
      create: (context) => DirWatchService(targetDir: dir),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: child,
    );
  }
}

class FileWatchProvider extends StatelessWidget {
  final Directory dir;
  final Widget child;

  const FileWatchProvider({
    super.key,
    required this.dir,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        FileWatchService>(
      create: (context) => FileWatchService(targetDir: dir),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: child,
    );
  }
}

bool _ifEventDirectUnder(FileSystemEvent? event, Directory watchedDir) {
  if (event == null) return true;
  final tgts = [event.pathW, event.pathW.dirname];
  if (event is FileSystemMoveEvent) {
    var destination = event.destination;
    if (destination != null) {
      tgts.add(destination.pathW);
      tgts.add(destination.pathW.dirname);
    }
  }
  return tgts.any((e) => e == watchedDir.pathW);
}
