import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/fs_watch.dart';
import 'package:rxdart/streams.dart';

abstract interface class CategoryRouteViewModel extends ChangeNotifier {
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
  );
}

class _CategoryRouteViewModelImpl extends ChangeNotifier
    implements CategoryRouteViewModel {
  final ModCategory _category;

  StreamSubscription<List<Mod>>? _modPathsSubscription;

  @override
  List<Mod> get modPaths => UnmodifiableListView(_modPaths);
  late List<Mod> _modPaths;

  @override
  void onFolderOpen() {
    openFolder(_category.path);
  }

  _CategoryRouteViewModelImpl({
    required AppStateService appStateService,
    required RecursiveFileSystemWatcher rootObserverService,
    required ModCategory category,
  }) : _category = category {
    final fseWatchService = createRelayFSEWatchService<Directory>(
      targetPath: category.path,
      host: rootObserverService,
    );
    _modPathsSubscription = CombineLatestStream.combine2(
      appStateService.showEnabledModsFirst,
      fseWatchService.entity,
      (showEnabledModsFirst, entity) =>
          entity.map((e) => Mod(path: e.path)).toList(growable: false)
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
            ),
    ).listen((value) {
      _modPaths = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _modPathsSubscription?.cancel();
    super.dispose();
  }
}
