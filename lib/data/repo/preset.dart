import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/io/mod_switcher.dart';
import 'package:genshin_mod_manager/data/latest_stream.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:genshin_mod_manager/domain/repo/preset.dart';
import 'package:rxdart/subjects.dart';

PresetService createPresetService({
  required AppStateService appStateService,
  required RecursiveFileSystemWatcher observerService,
}) {
  final decoded = jsonDecode(appStateService.presetData.latest);
  return _PresetServiceImpl(
    appStateService: appStateService,
    observerService: observerService,
    latestGlobal: _parseMap(decoded['global']),
    latestLocal: _parseMap(decoded['local']),
  );
}

class _PresetServiceImpl implements PresetService {
  late final StreamSubscription<String> _subscription;

  final AppStateService appStateService;
  final RecursiveFileSystemWatcher observerService;

  Map<String, Map<String, List<String>>> _curGlobal;
  Map<String, Map<String, List<String>>> _curLocal;

  @override
  LatestStream<List<String>> get globalPresets => vS2LS(_globalPresets.stream);
  final BehaviorSubject<List<String>> _globalPresets;

  @override
  LatestStream<List<String>> getLocalPresets(ModCategory category) {
    final stream = _localPresets.putIfAbsent(
      category.name,
      () => BehaviorSubject.seeded([]),
    );
    return vS2LS(stream.stream);
  }

  final Map<String, BehaviorSubject<List<String>>> _localPresets;

  _PresetServiceImpl({
    required this.appStateService,
    required this.observerService,
    required Map<String, Map<String, List<String>>> latestGlobal,
    required Map<String, Map<String, List<String>>> latestLocal,
  })  : _curGlobal = latestGlobal,
        _curLocal = latestLocal,
        _globalPresets = BehaviorSubject<List<String>>.seeded(
          List.unmodifiable(latestGlobal.keys),
        ),
        _localPresets = Map.fromEntries(
          latestLocal.entries.map(
            (e) => MapEntry(
              e.key,
              BehaviorSubject.seeded(
                List.unmodifiable(e.value.keys),
              ),
            ),
          ),
        ) {
    _subscription = appStateService.presetData.stream.listen((event) {
      final decoded = jsonDecode(event);
      _curGlobal = _parseMap(decoded['global']);
      _curLocal = _parseMap(decoded['local']);
      _globalPresets.add(List.unmodifiable(_curGlobal.keys));
      for (final category in _curLocal.entries) {
        final stream = _localPresets[category.key];
        if (stream != null) {
          stream.add(List.unmodifiable(category.value.keys));
        } else {
          _localPresets[category.key] = BehaviorSubject.seeded(
            List.unmodifiable(category.value.keys),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _globalPresets.close();
    for (final e in _localPresets.values) {
      e.close();
    }
    _subscription.cancel();
  }

  @override
  void addGlobalPreset(String name) {
    Map<String, List<String>> data = {};
    final modRoot = appStateService.modRoot.latest;
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

  @override
  void addLocalPreset(ModCategory category, String name) {
    final categoryDir = category.path;
    List<String> data = getFSEUnder<Directory>(categoryDir)
        .map((e) => e.path.pBasename)
        .where((e) => e.pIsEnabled)
        .toList(growable: false);
    _curLocal.putIfAbsent(category.name, () => {})[name] = data;
    _writeBack();
  }

  @override
  void removeGlobalPreset(String name) {
    _curGlobal.remove(name);
    _writeBack();
  }

  @override
  void removeLocalPreset(ModCategory category, String name) {
    final localPreset = _curLocal[category.name];
    if (localPreset == null) return;
    localPreset.remove(name);
    _writeBack();
  }

  void _writeBack() {
    final data = {
      'global': _curGlobal,
      'local': _curLocal,
    };
    final encoded = jsonEncode(data);
    appStateService.setPresetData(encoded);
  }

  @override
  void setGlobalPreset(String name) {
    final directives = _curGlobal[name];
    if (directives == null) return;
    _toggleGlobal(directives);
    observerService.forceUpdate();
  }

  @override
  void setLocalPreset(ModCategory category, String name) {
    final directives = _curLocal[category.name]?[name];
    if (directives == null) return;
    _toggleLocal(category.path, directives);
    observerService.forceUpdate();
  }

  void _toggleGlobal(Map<String, List<String>> directives) {
    for (final category in directives.entries) {
      final shouldBeEnabled = category.value;
      final categoryDir = appStateService.modRoot.latest.pJoin(category.key);
      _toggleCategory(categoryDir, shouldBeEnabled);
    }
  }

  void _toggleLocal(String categoryPath, List<String> shouldBeEnabled) {
    _toggleCategory(categoryPath, shouldBeEnabled);
  }

  void _toggleCategory(String categoryPath, List<String> shouldBeEnabled) {
    final shaderFixes =
        appStateService.modExecFile.latest.pDirname.pJoin(kShaderFixes);
    final currentEnabled = getFSEUnder<Directory>(categoryPath)
        .map((e) => e.path.pBasename)
        .where((e) => e.pIsEnabled)
        .toList(growable: false);
    final shouldBeOff =
        currentEnabled.where((e) => !shouldBeEnabled.contains(e));
    for (var mod in shouldBeOff) {
      final modDir = categoryPath.pJoin(mod);
      disable(
        shaderFixesPath: shaderFixes,
        modPathW: modDir,
      );
    }
    final shouldBeOn =
        shouldBeEnabled.where((e) => !currentEnabled.contains(e));
    for (var mod in shouldBeOn) {
      final modDir = categoryPath.pJoin(mod.pDisabledForm);
      enable(
        shaderFixesPath: shaderFixes,
        modPath: modDir,
      );
    }
  }
}

Map<String, Map<String, List<String>>> _parseMap(dynamic data) {
  final Map<String, Map<String, List<String>>> parsed = {};
  data.forEach((k, v) {
    final forEachCategory = _forEachPreset(k, v);
    if (forEachCategory == null) return;
    parsed[k] = forEachCategory;
  });
  return parsed;
}

Map<String, List<String>>? _forEachPreset(k, v) {
  if (k is! String) return null;
  if (v is! Map) return null;
  final Map<String, List<String>> b = {};
  v.forEach((k, v) {
    final forEachCategory = _forEachCategory(k, v);
    if (forEachCategory == null) return;
    b[k] = forEachCategory;
  });
  return b;
}

List<String>? _forEachCategory(k, v) {
  if (k is! String) return null;
  if (v is! List) return null;
  final List<String> c = [];
  for (final e in v) {
    if (e is! String) continue;
    c.add(e);
  }
  return c;
}
