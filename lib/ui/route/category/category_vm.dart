import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem.dart';

abstract interface class CategoryRouteViewModel extends ChangeNotifier {
  List<Mod> get modPaths;

  void onFolderOpen();
}

CategoryRouteViewModel createCategoryRouteViewModel({
  required AppStateService appStateService,
  required RecursiveFSWatchService rootObserverService,
  required ModCategory category,
}) {
  return _CategoryRouteViewModelImpl(
    appStateService: appStateService,
    rootObserverService: rootObserverService,
    category: category,
  );
}

class _CategoryRouteViewModelImpl extends ChangeNotifier
    implements CategoryRouteViewModel {
  final RelayFSEWatchService<Directory> _dirWatchService;
  final AppStateService _appStateService;
  final ModCategory _category;

  @override
  List<Mod> get modPaths => UnmodifiableListView(_modPaths);
  late List<Mod> _modPaths;

  @override
  void onFolderOpen() {
    openFolder(_category.path);
  }

  _CategoryRouteViewModelImpl({
    required AppStateService appStateService,
    required RecursiveFSWatchService rootObserverService,
    required ModCategory category,
  })  : _category = category,
        _appStateService = appStateService,
        _dirWatchService = createRelayFSEWatchService<Directory>(
          targetPath: category.path,
          host: rootObserverService,
        ) {
    _getModList();
    _dirWatchService.addListener(_listener);
    _appStateService.addListener(_listener);
  }

  @override
  void dispose() {
    _appStateService.removeListener(_listener);
    _dirWatchService.removeListener(_listener);
    _dirWatchService.dispose();
    super.dispose();
  }

  void _listener() {
    _getModList();
    notifyListeners();
  }

  void _getModList() {
    final enabledFirst = _appStateService.showEnabledModsFirst;
    _modPaths = _dirWatchService.entities
        .map((e) => Mod(path: e.path))
        .toList(growable: false)
      ..sort(
        (a, b) {
          final aBase = a.path.pBasename;
          final bBase = b.path.pBasename;
          if (enabledFirst) {
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
