import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class HomeShellViewModel implements BaseViewModel {
  List<ModCategory> get modCategories;

  bool get runTogether;

  bool get showFolderIcon;

  void onWindowFocus();

  void runMigoto();

  void runLauncher();
}

HomeShellViewModel createViewModel({
  required AppStateService appStateService,
  required RecursiveFileSystemWatcher recursiveFileSystemWatcher,
}) {
  return _HomeShellViewModelImpl(
    appStateService: appStateService,
    recursiveFileSystemWatcher: recursiveFileSystemWatcher,
    rootWatchService: createFSEPathsWatcher<Directory>(
      targetPath: appStateService.modRoot.latest,
      watcher: recursiveFileSystemWatcher,
    ),
    categoryIconFolderObserverService: createCategoryIconWatcher(
      targetPath: appStateService.modRoot.latest,
    ),
  );
}

class _HomeShellViewModelImpl extends ChangeNotifier
    implements HomeShellViewModel {
  late final StreamSubscription<List<ModCategory>> _modCategoriesSubscription;
  late final StreamSubscription<bool> _runTogetherSubscription;
  late final StreamSubscription<bool> _showFolderIconSubscription;

  final AppStateService appStateService;
  final RecursiveFileSystemWatcher recursiveFileSystemWatcher;
  final FSEPathsWatcher rootWatchService;
  final FSEPathsWatcher categoryIconFolderObserverService;

  @override
  List<ModCategory> get modCategories => UnmodifiableListView(_modCategories);
  List<ModCategory> _modCategories;

  @override
  bool get runTogether => _runTogether;
  bool _runTogether;

  @override
  bool get showFolderIcon => _showFolderIcon;
  bool _showFolderIcon;

  _HomeShellViewModelImpl({
    required this.appStateService,
    required this.recursiveFileSystemWatcher,
    required this.rootWatchService,
    required this.categoryIconFolderObserverService,
  })  : _runTogether = appStateService.runTogether.latest,
        _showFolderIcon = appStateService.showFolderIcon.latest,
        _modCategories = _getCategories(
          rootWatchService.paths.latest,
          categoryIconFolderObserverService.paths.latest,
          appStateService.modRoot.latest,
        ) {
    _modCategoriesSubscription = CombineLatestStream.combine3(
      rootWatchService.paths.stream,
      categoryIconFolderObserverService.paths.stream,
      appStateService.modRoot.stream,
      _getCategories,
    ).listen((event) {
      _modCategories = event;
      notifyListeners();
    });

    _runTogetherSubscription =
        appStateService.runTogether.stream.listen((event) {
      _runTogether = event;
      notifyListeners();
    });

    _showFolderIconSubscription =
        appStateService.showFolderIcon.stream.listen((event) {
      _showFolderIcon = event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _showFolderIconSubscription.cancel();
    _runTogetherSubscription.cancel();
    _modCategoriesSubscription.cancel();
    rootWatchService.dispose();
    categoryIconFolderObserverService.dispose();
    super.dispose();
  }

  @override
  void onWindowFocus() {
    recursiveFileSystemWatcher.forceUpdate();
  }

  @override
  void runLauncher() {
    final launcher = appStateService.launcherFile.latest;
    runProgram(File(launcher));
  }

  @override
  void runMigoto() {
    final path = appStateService.modExecFile.latest;
    runProgram(File(path));
  }

  static List<ModCategory> _getCategories(
      List<String> root, List<String> icons, String modRoot) {
    return List.unmodifiable(root.map((e) {
      final imageFile = findPreviewFileInString(icons, name: e);
      return ModCategory(
        path: e,
        name: e.pBasename,
        iconPath: imageFile,
      );
    }));
  }
}
