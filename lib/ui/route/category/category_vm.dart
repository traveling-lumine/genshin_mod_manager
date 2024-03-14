import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';
import 'package:rxdart/streams.dart';

/// A viewmodel for the category route.
abstract interface class CategoryRouteViewModel implements BaseViewModel {
  /// Bound mods.
  List<Mod>? get modPaths;

  /// Call when you want to open the folder.
  void onFolderOpen();
}

/// Creates a [CategoryRouteViewModel].
CategoryRouteViewModel createCategoryRouteViewModel({
  required final AppStateService appStateService,
  required final RecursiveFileSystemWatcher rootObserverService,
  required final ModCategory category,
}) =>
    _CategoryRouteViewModelImpl(
      appStateService: appStateService,
      category: category,
      modFoldersWatcher: createModsWatcher(
        category: category,
        watcher: rootObserverService,
      ),
    );

class _CategoryRouteViewModelImpl extends ChangeNotifier
    implements CategoryRouteViewModel {
  _CategoryRouteViewModelImpl({
    required final AppStateService appStateService,
    required this.category,
    required this.modFoldersWatcher,
  }) {
    _modPathsSubscription = CombineLatestStream.combine2(
      appStateService.showEnabledModsFirst.stream,
      modFoldersWatcher.mods.stream,
      _getModPaths,
    ).listen((final value) {
      modPaths = value;
      notifyListeners();
    });
  }

  final ModsWatcher modFoldersWatcher;
  final ModCategory category;
  late final StreamSubscription<List<Mod>> _modPathsSubscription;

  @override
  List<Mod>? modPaths;

  @override
  void dispose() {
    _modPathsSubscription.cancel();
    modFoldersWatcher.dispose();
    super.dispose();
  }

  @override
  void onFolderOpen() {
    openFolder(category.path);
  }

  static List<Mod> _getModPaths(
    final bool showEnabledModsFirst,
    final List<Mod> entity,
  ) {
    final list = List.of(entity, growable: false)
      ..sort(
        (final a, final b) {
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
    return UnmodifiableListView(list);
  }
}
