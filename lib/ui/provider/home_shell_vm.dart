import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

class RootWatcher {
  RootWatcher({
    required this.modRoot,
  }) {
    final dir = Directory(modRoot);
    _controller.add(
      dir
          .listSync()
          .whereType<Directory>()
          .map(
            (final event) => ModCategory(
              path: event.path,
              name: event.path,
            ),
          )
          .toList(),
    );

    _subscription = dir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .listen(_listen);
  }

  final StreamController<List<ModCategory>> _controller =
      StreamController<List<ModCategory>>();
  final String modRoot;
  late final StreamSubscription<FileSystemEvent> _subscription;
  Stream<List<ModCategory>> categories;

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }

  void _listen(final FileSystemEvent event) {
    _controller;
  }
}

@riverpod
class HomeShellNotifier extends _$HomeShellNotifier {

  final resourcePath =
  Platform.resolvedExecutable.pDirname.pJoin(_resourceDir);
  Directory(resourcePath).createSync(recursive: true);
  static const _resourceDir = 'Resources';

  @override
  List<ModCategory> build() {
    return [];
  }
}

abstract interface class HomeShellViewModel implements BaseViewModel {
  List<ModCategory>? get modCategories;

  bool? get runTogether;

  bool? get showFolderIcon;

  void onWindowFocus();

  void runMigoto();

  void runLauncher();
}

HomeShellViewModel createViewModel({
  required final AppStateService appStateService,
  required final RecursiveFileSystemWatcher recursiveFileSystemWatcher,
}) =>
    _HomeShellViewModelImpl(
      appStateService: appStateService,
      recursiveFileSystemWatcher: recursiveFileSystemWatcher,
    );

class _HomeShellViewModelImpl extends ChangeNotifier
    implements HomeShellViewModel {
  _HomeShellViewModelImpl({
    required this.appStateService,
    required this.recursiveFileSystemWatcher,
  }) {
    _asmr = appStateService.modRoot.stream.listen((final event) {
      final categoryWatcher = createFSEPathsWatcher<Directory>(
        targetPath: event,
        watcher: recursiveFileSystemWatcher,
      );
      _categoryWatcher?.dispose();
      _categoryWatcher = categoryWatcher;
      final categoryIconFolderObserverService = createCategoryIconWatcher(
        targetPath: event,
      );
      _categoryIconFolderObserverService?.dispose();
      _categoryIconFolderObserverService = categoryIconFolderObserverService;
      unawaited(_modCategoriesSubscription?.cancel());
      _modCategoriesSubscription = CombineLatestStream.combine3(
        categoryWatcher.paths.stream,
        categoryIconFolderObserverService.paths.stream,
        appStateService.modRoot.stream,
        _getCategories,
      ).listen((final event) {
        _modCategories = event
          ..sort((final a, final b) => compareNatural(a.name, b.name));
        notifyListeners();
      });
    });

    _runTogetherSubscription =
        appStateService.runTogether.stream.listen((final event) {
      _runTogether = event;
      notifyListeners();
    });

    _showFolderIconSubscription =
        appStateService.showFolderIcon.stream.listen((final event) {
      _showFolderIcon = event;
      notifyListeners();
    });
  }

  late final StreamSubscription<bool> _runTogetherSubscription;
  late final StreamSubscription<bool> _showFolderIconSubscription;
  late final StreamSubscription<String> _asmr;

  final AppStateService appStateService;
  final RecursiveFileSystemWatcher recursiveFileSystemWatcher;

  FSEPathsWatcher? _categoryWatcher;
  FSEPathsWatcher? _categoryIconFolderObserverService;
  StreamSubscription<List<ModCategory>>? _modCategoriesSubscription;

  @override
  List<ModCategory>? get modCategories => _modCategories;
  List<ModCategory>? _modCategories;

  @override
  bool? get runTogether => _runTogether;
  bool? _runTogether;

  @override
  bool? get showFolderIcon => _showFolderIcon;
  bool? _showFolderIcon;

  @override
  void dispose() {
    unawaited(_showFolderIconSubscription.cancel());
    unawaited(_runTogetherSubscription.cancel());
    _categoryWatcher?.dispose();
    _categoryIconFolderObserverService?.dispose();
    unawaited(_modCategoriesSubscription?.cancel());
    unawaited(_asmr.cancel());
    super.dispose();
  }

  @override
  void onWindowFocus() {
    recursiveFileSystemWatcher.forceUpdate();
  }

  @override
  void runLauncher() {
    final launcher = appStateService.launcherFile.latest;
    if (launcher == null) return;
    runProgram(File(launcher));
  }

  @override
  void runMigoto() {
    final path = appStateService.modExecFile.latest;
    if (path == null) return;
    runProgram(File(path));
  }

  static List<ModCategory> _getCategories(
    final List<String> root,
    final List<String> icons,
    final String modRoot,
  ) =>
      root.map((final catPath) {
        final imageFile = findPreviewFileInString(icons, name: catPath);
        return ModCategory(
          path: catPath,
          name: catPath.pBasename,
          iconPath: imageFile,
        );
      }).toList(growable: false);
}
