import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/route_refresh_service.dart';
import 'package:go_router/go_router.dart';
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

class RootWatchService with ChangeNotifier {
  final _listEquality = const ListEquality();
  final Directory targetDir;
  final GlobalKey<NavigatorState> navigationKey;
  final RouteRefreshService routeRefreshService;

  late List<String> _categories;

  List<String> get categories => _categories;

  RootWatchService(
      {required this.targetDir,
      required this.navigationKey,
      required this.routeRefreshService}) {
    _categories = [];
    _getDirs();
  }

  void update(FileSystemEvent? event) {
    if (!_ifEventDirectUnder(event, targetDir)) return;
    final isEqual = _getDirs();
    if (isEqual) return;

    final pathSegments = GoRouter.of(navigationKey.currentContext!)
        .routeInformationProvider
        .value
        .uri
        .pathSegments;
    // GoRouterState.of(navigationKey.currentState!.context).uri.pathSegments;
    if (pathSegments.length >= 2 &&
        pathSegments[0] == 'category' &&
        !_categories.contains(pathSegments[1])) {
      final prevCategory = pathSegments[1];
      final index = _searchIndex(prevCategory);
      if (index == -1) {
        routeRefreshService.refresh('/setting');
      } else {
        routeRefreshService.refresh('/category/${_categories[index]}');
      }
    }
    notifyListeners();
  }

  bool _getDirs() {
    final before = _categories;
    try {
      _categories = getDirsUnder(targetDir)
          .map((e) => e.pathW.basename.asString)
          .toList(growable: false)
        ..sort(compareNatural);
    } on PathNotFoundException {
      _categories = [];
    }
    return _listEquality.equals(before, _categories);
  }

  int _searchIndex(String category) {
    int lo = 0;
    int hi = _categories.length;
    while (lo < hi) {
      int mid = lo + ((hi - lo) >> 1);
      if (compareNatural(_categories[mid], category) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo == _categories.length) {
      lo -= 1;
    }
    return lo;
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
