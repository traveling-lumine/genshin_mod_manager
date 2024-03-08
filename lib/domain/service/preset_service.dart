import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/io/mod_switcher.dart';
import 'package:genshin_mod_manager/domain/service/folder_observer_service.dart';

import 'app_state_service.dart';

class PresetService with ChangeNotifier {
  AppStateService? _appStateService;
  RecursiveObserverService? _observerService;
  Map<String, Map<String, List<String>>> _curGlobal = {};
  Map<String, Map<String, List<String>>> _curLocal = {};

  PresetService();

  void update(AppStateService data, RecursiveObserverService observerService) {
    _appStateService = data;
    _observerService = observerService;
    if (_shouldUpdate(data.presetData)) {
      _update(data.presetData);
    }
  }

  List<String> getGlobalPresets() {
    return _curGlobal.keys.toList(growable: false);
  }

  List<String> getLocalPresets(String category) {
    try {
      return _curLocal[category]!.keys.toList(growable: false);
    } catch (e) {
      return [];
    }
  }

  void addGlobalPreset(String name) {
    Map<String, List<String>> data = {};
    final modRoot = _appStateService!.modRoot;
    final categoryDirs = getFSEUnder<Directory>(modRoot);
    for (var categoryDir in categoryDirs) {
      final category = categoryDir.path.pBasename;
      data[category] = getFSEUnder<Directory>(categoryDir.path)
          .map((e) => e.path.pBasename)
          .where((e) => e.pIsEnabled)
          .toList(growable: false);
    }
    _curGlobal[name] = data;
    _writeBack();
  }

  void addLocalPreset(String category, String name) {
    final modRoot = _appStateService!.modRoot;
    final categoryDir = modRoot.pJoin(category);
    List<String> data = getFSEUnder<Directory>(categoryDir)
        .map((e) => e.path.pBasename)
        .where((e) => e.pIsEnabled)
        .toList(growable: false);
    _curLocal.putIfAbsent(category, () => {})[name] = data;
    _writeBack();
  }

  void removeGlobalPreset(String name) {
    _curGlobal.remove(name);
    _writeBack();
  }

  void removeLocalPreset(String category, String name) {
    _curLocal[category]?.remove(name);
    _writeBack();
  }

  void setGlobalPreset(String name) {
    final directives = _curGlobal[name];
    if (directives == null) return;
    _toggleGlobal(directives);
    _observerService!.forceUpdate();
  }

  void setLocalPreset(String category, String name) {
    final locCat = _curLocal[category];
    if (locCat == null) return;
    final directives = locCat[name];
    if (directives == null) return;
    _toggleLocal(category, directives);
    _observerService!.forceUpdate();
  }

  void _toggleGlobal(Map<String, List<String>> directives) {
    final shaderFixes =
        _appStateService!.modExecFile.pDirname.pJoin(kShaderFixes);
    for (var category in directives.entries) {
      final shouldBeEnabled = category.value;
      final categoryDir = _appStateService!.modRoot.pJoin(category.key);
      _toggleCategory(categoryDir, shouldBeEnabled, shaderFixes);
    }
  }

  void _toggleLocal(String category, List<String> shouldBeEnabled) {
    final shaderFixes =
        _appStateService!.modExecFile.pDirname.pJoin(kShaderFixes);
    final categoryDir = _appStateService!.modRoot.pJoin(category);
    _toggleCategory(categoryDir, shouldBeEnabled, shaderFixes);
  }

  void _toggleCategory(
    String categoryDir,
    List<String> shouldBeEnabled,
    String shaderFixes,
  ) {
    final currentEnabled = getFSEUnder<Directory>(categoryDir)
        .map((e) => e.path.pBasename)
        .where((e) => e.pIsEnabled)
        .toList(growable: false);
    final shouldBeOff =
        currentEnabled.where((e) => !shouldBeEnabled.contains(e));
    for (var mod in shouldBeOff) {
      final modDir = categoryDir.pJoin(mod);
      disable(
        shaderFixesPath: shaderFixes,
        modPathW: modDir,
      );
    }
    final shouldBeOn =
        shouldBeEnabled.where((e) => !currentEnabled.contains(e));
    for (var mod in shouldBeOn) {
      final modDir = categoryDir.pJoin(mod.pDisabledForm);
      enable(
        shaderFixesPath: shaderFixes,
        modPath: modDir,
      );
    }
  }

  void _writeBack() {
    final presetData = _getStringRepresentation();
    final appStateService = _appStateService!;

    notifyListeners();

    if (appStateService.presetData != presetData) {
      appStateService.presetData = presetData;
    }
  }

  bool _shouldUpdate(String prevString) {
    var bool = prevString != _getStringRepresentation();
    return bool;
  }

  String _getStringRepresentation() {
    return jsonEncode({
      'global': _curGlobal,
      'local': _curLocal,
    });
  }

  void _update(String presetData) {
    bool doUpdate = false;
    dynamic data;
    try {
      data = jsonDecode(presetData);
    } catch (e) {
      return;
    }
    const equality = DeepCollectionEquality();
    try {
      final parsedGlobal = _parseMap(data['global']);
      final globalDiffers = !equality.equals(parsedGlobal, _curGlobal);
      if (globalDiffers) {
        _curGlobal = parsedGlobal;
        doUpdate = true;
      }
    } catch (e) {
      // do nothing
    }
    try {
      final parsedLocal = _parseMap(data['local']);
      final localDiffers = !equality.equals(parsedLocal, _curLocal);
      if (localDiffers) {
        _curLocal = parsedLocal;
        doUpdate = true;
      }
    } catch (e) {
      // do nothing
    }
    if (doUpdate) {
      notifyListeners();
    }
  }

  Map<String, Map<String, List<String>>> _parseMap(dynamic data) {
    final Map<String, Map<String, List<String>>> parsedGlobal = {};
    data.forEach((k, v) {
      if (k is! String) return;
      if (v is! Map) return;
      final Map<String, List<String>> b = {};
      v.forEach((k, v) {
        if (k is! String) return;
        if (v is! List) return;
        final List<String> c = [];
        for (final e in v) {
          if (e is! String) continue;
          c.add(e);
        }
        b[k] = c;
      });
      parsedGlobal[k] = b;
    });
    return parsedGlobal;
  }
}
