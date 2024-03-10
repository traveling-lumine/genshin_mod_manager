import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/folder_observer.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/fs_watch.dart';

abstract interface class HomeShellViewModel extends ChangeNotifier {
  List<ModCategory> get modCategories;

  bool get runTogether;

  bool get showFolderIcon;

  void onWindowFocus();

  void runMigoto();

  void runLauncher();
}

HomeShellViewModel createViewModel({
  required AppStateService appStateService,
  required RecursiveFileSystemWatcher recursiveObserverService,
}) {
  return _HomeShellViewModelImpl(
    appStateService: appStateService,
    recursiveObserverService: recursiveObserverService,
  );
}

class _HomeShellViewModelImpl extends ChangeNotifier
    implements HomeShellViewModel {
  final AppStateService _appStateService;
  final CategoryIconFolderObserverService _categoryIconFolderObserverService;
  final RecursiveFileSystemWatcher _recursiveObserverService;
  final RootWatchService _rootWatchService;

  late final StreamSubscription<FileSystemEvent?> _subscription;

  @override
  List<ModCategory> get modCategories => UnmodifiableListView(_modCategories);
  late List<ModCategory> _modCategories = _getModCategories();

  @override
  bool get runTogether => _runTogether;
  late bool _runTogether = _appStateService.runTogether;

  @override
  bool get showFolderIcon => _showFolderIcon;
  late bool _showFolderIcon = _appStateService.showFolderIcon;

  _HomeShellViewModelImpl({
    required AppStateService appStateService,
    required RecursiveFileSystemWatcher recursiveObserverService,
  })  : _appStateService = appStateService,
        _categoryIconFolderObserverService = CategoryIconFolderObserverService(
          targetPath: appStateService.modRoot,
        ),
        _recursiveObserverService = recursiveObserverService,
        _rootWatchService = RootWatchService(
          targetPath: appStateService.modRoot,
        ) {
    _appStateService.addListener(_onAppState);
    _categoryIconFolderObserverService.addListener(_onCategoryIconFolder);
    _subscription = _recursiveObserverService.event.listen(_onRecursive);
    _rootWatchService.addListener(_onRoot);
  }

  @override
  void dispose() {
    _appStateService.removeListener(_onAppState);
    _categoryIconFolderObserverService.removeListener(_onCategoryIconFolder);
    _subscription.cancel();
    _rootWatchService.removeListener(_onRoot);
    super.dispose();
  }

  @override
  void onWindowFocus() {
    _recursiveObserverService.forceUpdate();
  }

  @override
  void runLauncher() {
    final launcher = _appStateService.launcherFile;
    runProgram(File(launcher));
  }

  @override
  void runMigoto() {
    final path = _appStateService.modExecFile;
    runProgram(File(path));
  }

  void _onRecursive(FileSystemEvent? event) {
    _rootWatchService.update(event);
  }

  void _onAppState() {
    _modCategories = _getModCategories();
    _runTogether = _appStateService.runTogether;
    _showFolderIcon = _appStateService.showFolderIcon;
    notifyListeners();
  }

  void _onCategoryIconFolder() {
    _modCategories = _getModCategories();
    notifyListeners();
  }

  void _onRoot() {
    _modCategories = _getModCategories();
    notifyListeners();
  }

  List<ModCategory> _getModCategories() {
    final imageFiles = _categoryIconFolderObserverService.curFiles
        .map((e) => e.path)
        .toList(growable: false);
    final categories = _rootWatchService.categories;
    final modRoot = _appStateService.modRoot;
    var list = categories.map(
      (e) {
        final imageFilePath = findPreviewFileInString(imageFiles, name: e);
        return ModCategory(
          path: modRoot.pJoin(e),
          name: e,
          iconPath: imageFilePath,
        );
      },
    ).toList(growable: false);
    return list;
  }
}
