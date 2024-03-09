import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/ui/service/app_state_service.dart';
import 'package:genshin_mod_manager/ui/service/folder_observer_service.dart';

abstract interface class CategoryRouteViewModel extends ChangeNotifier {
  List<Mod> get modPaths;

  void onFolderOpen();
}

class CategoryRouteViewModelImpl extends ChangeNotifier
    implements CategoryRouteViewModel {
  final AppStateService _appStateService;
  final RecursiveObserverService _rootObserverService;
  final String _category;
  late final DirWatchService _dirWatchService;

  List<Mod> _modPaths = [];

  @override
  List<Mod> get modPaths => UnmodifiableListView(_modPaths);

  @override
  void onFolderOpen() {
    openFolder(_appStateService.modRoot.pJoin(_category));
  }

  set modPaths(List<Mod> value) {
    _modPaths = value;
    notifyListeners();
  }

  CategoryRouteViewModelImpl({
    required AppStateService appStateService,
    required RecursiveObserverService rootObserverService,
    required String category,
  })  : _category = category,
        _rootObserverService = rootObserverService,
        _appStateService = appStateService {
    final modRootPath = _appStateService.modRoot;
    final categoryPath = modRootPath.pJoin(_category);
    _dirWatchService = DirWatchService(targetPath: categoryPath);
    _appStateService.addListener(appStateServiceUpdate);
    _rootObserverService.addListener(rootObserverServiceUpdate);
    updateModPaths();
  }

  @override
  void dispose() {
    _appStateService.removeListener(appStateServiceUpdate);
    _rootObserverService.removeListener(rootObserverServiceUpdate);
    super.dispose();
  }

  void appStateServiceUpdate() {
    updateModPaths();
  }

  void rootObserverServiceUpdate() {
    _dirWatchService.update(_rootObserverService.lastEvent);
    updateModPaths();
  }

  void updateModPaths() {
    final enabledFirst = _appStateService.showEnabledModsFirst;
    modPaths = _dirWatchService.curEntities
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
