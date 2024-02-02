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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class DirectFolderObserverService with ChangeNotifier {
  final Directory targetDir;

  List<Directory> _curDirs;

  List<Directory> get curDirs => _curDirs;

  DirectFolderObserverService({required this.targetDir})
      : _curDirs = getDirsUnder(targetDir);

  void update(FileSystemEvent? event) {
    if (_ifEventDirectUnder(event, targetDir)) {
      _curDirs = getDirsUnder(targetDir);
      notifyListeners();
    }
  }
}

class DirectFileObserverService with ChangeNotifier {
  final Directory targetDir;

  List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  DirectFileObserverService({required this.targetDir})
      : _curFiles = getFilesUnder(targetDir);

  void update(FileSystemEvent? event) {
    if (_ifEventDirectUnder(event, targetDir)) {
      _curFiles = getFilesUnder(targetDir);
      notifyListeners();
    }
  }
}

class DirectDirService extends StatelessWidget {
  final Directory dir;
  final Widget child;

  const DirectDirService({
    super.key,
    required this.dir,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        DirectFolderObserverService>(
      key: ValueKey(dir),
      create: (context) => DirectFolderObserverService(targetDir: dir),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: child,
    );
  }
}

class DirectFileService extends StatelessWidget {
  final Directory dir;
  final Widget child;

  const DirectFileService({
    super.key,
    required this.dir,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        DirectFileObserverService>(
      create: (context) => DirectFileObserverService(targetDir: dir),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: child,
    );
  }
}

bool _ifEventDirectUnder(FileSystemEvent? event, Directory watchedDir) {
  if (event == null) return true;
  final eventPathW = PathW(event.path);
  final wDirPath = watchedDir.pathW;
  final sameDir = eventPathW == wDirPath;
  if (sameDir) return true;
  final within = eventPathW.isWithin(wDirPath);
  if (!within) return false;
  final dirCheck = eventPathW.dirname == wDirPath;
  return dirCheck;
}
