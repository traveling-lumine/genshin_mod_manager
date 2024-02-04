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

class DirWatchService with ChangeNotifier {
  final Directory targetDir;

  List<Directory> _curDirs;

  List<Directory> get curDirs => _curDirs;

  DirWatchService({required this.targetDir})
      : _curDirs = getDirsUnder(targetDir);

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetDir)) return;
    _curDirs = getDirsUnder(targetDir);
    notifyListeners();
  }
}

class FileWatchService with ChangeNotifier {
  final Directory targetDir;

  List<File> _curFiles;

  List<File> get curFiles => _curFiles;

  FileWatchService({required this.targetDir})
      : _curFiles = getFilesUnder(targetDir);

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetDir)) return;
    _curFiles = getFilesUnder(targetDir);
    notifyListeners();
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
