import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';
import 'package:rxdart/streams.dart';

abstract interface class CategoryRouteViewModel implements BaseViewModel {
  List<Mod> get modPaths;

  void onFolderOpen();
}

CategoryRouteViewModel createCategoryRouteViewModel({
  required AppStateService appStateService,
  required RecursiveFileSystemWatcher rootObserverService,
  required ModCategory category,
}) {
  return _CategoryRouteViewModelImpl(
    appStateService: appStateService,
    rootObserverService: rootObserverService,
    category: category,
    fseWatchService: createProxyFSEntityWatcher<Directory>(
      targetPath: category.path,
      watcher: rootObserverService,
    ),
  );
}

class _CategoryRouteViewModelImpl extends ChangeNotifier
    implements CategoryRouteViewModel {
  final FSEntityWatcher<Directory> fseWatchService;
  final ModCategory category;

  late final StreamSubscription<List<Mod>> _modPathsSubscription;

  @override
  List<Mod> get modPaths => UnmodifiableListView(_modPaths);
  List<Mod> _modPaths;

  _CategoryRouteViewModelImpl({
    required AppStateService appStateService,
    required RecursiveFileSystemWatcher rootObserverService,
    required this.category,
    required this.fseWatchService,
  }) : _modPaths = _getModPaths(
          appStateService.showEnabledModsFirst.latest,
          fseWatchService.entity.latest,
        ) {
    _modPathsSubscription = CombineLatestStream.combine2(
      appStateService.showEnabledModsFirst.stream,
      fseWatchService.entity.stream,
      _getModPaths,
    ).listen((value) {
      _modPaths = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _modPathsSubscription.cancel();
    fseWatchService.dispose();
    super.dispose();
  }

  @override
  void onFolderOpen() {
    openFolder(category.path);
  }

  static List<Mod> _getModPaths(
      bool showEnabledModsFirst, List<Directory> entity) {
    return entity.map((e) => Mod(path: e.path)).toList(growable: false)
      ..sort(
        (a, b) {
          final aBase = a.path.pBasename;
          final bBase = b.path.pBasename;
          if (showEnabledModsFirst) {
            final aEnabled = aBase.pIsEnabled;
            final bEnabled = bBase.pIsEnabled;
            if (aEnabled && !bEnabled) {
              return -1;
            } else if (!aEnabled && bEnabled) {
              return 1;
            }
          }
          final aLower = aBase.pEnabledForm.toLowerCase();
          final bLower = bBase.pEnabledForm.toLowerCase();
          return aLower.compareTo(bLower);
        },
      );
  }
}
