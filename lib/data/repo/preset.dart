import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/mod_switcher.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/mapper/latest_stream.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:genshin_mod_manager/domain/repo/preset.dart';
import 'package:rxdart/subjects.dart';

/// A service that manages presets.
PresetService createPresetService({
  required final AppStateService appStateService,
  required final RecursiveFileSystemWatcher observerService,
}) =>
    _PresetServiceImpl(
      appStateService: appStateService,
      observerService: observerService,
    );

class _PresetServiceImpl implements PresetService {
  _PresetServiceImpl({
    required this.appStateService,
    required this.observerService,
  }) {
    _subscription = appStateService.presetData.stream.listen((final event) {
      final Map<String, dynamic> decoded = jsonDecode(event);
      _curGlobal = _parseMap(decoded['global']);
      _curLocal = _parseMap(decoded['local']);
      _globalPresets.add(_curGlobal.keys.toList());
      for (final category in _curLocal.entries) {
        // ignore: close_sinks
        final stream = _localPresets[category.key];
        if (stream != null) {
          stream.add(category.value.keys.toList());
        } else {
          _localPresets[category.key] =
              BehaviorSubject.seeded(category.value.keys.toList());
        }
      }
    });
  }

  late final StreamSubscription<String> _subscription;

  final AppStateService appStateService;
  final RecursiveFileSystemWatcher observerService;

  var _curGlobal = <String, Map<String, List<String>>>{};
  var _curLocal = <String, Map<String, List<String>>>{};

  @override
  LatestStream<List<String>> get globalPresets => vS2LS(_globalPresets);
  final _globalPresets = BehaviorSubject<List<String>>();

  @override
  LatestStream<List<String>> getLocalPresets(final ModCategory category) {
    // ignore: close_sinks
    final stream = _localPresets.putIfAbsent(
      category.name,
      () => BehaviorSubject.seeded([]),
    );
    return vS2LS(stream);
  }

  final _localPresets = <String, BehaviorSubject<List<String>>>{};

  @override
  void dispose() {
    unawaited(_globalPresets.close());
    for (final e in _localPresets.values) {
      unawaited(e.close());
    }
    unawaited(_subscription.cancel());
  }

  @override
  Future<void> addGlobalPreset(final String name) async {
    final data = <String, List<String>>{};
    final modRoot = appStateService.modRoot.latest;
    if (modRoot == null) {
      return;
    }
    final categoryDirs = getUnder<Directory>(modRoot);
    for (final categoryDir in categoryDirs) {
      final category = categoryDir.pBasename;
      data[category] = getUnder<Directory>(categoryDir)
          .map((final e) => e.pBasename)
          .where((final e) => e.pIsEnabled)
          .toList();
    }
    _curGlobal[name] = data;
    _writeBack();
  }

  @override
  Future<void> addLocalPreset(
    final ModCategory category,
    final String name,
  ) async {
    final categoryDir = category.path;
    final data = getUnder<Directory>(categoryDir)
        .map((final e) => e.pBasename)
        .where((final e) => e.pIsEnabled)
        .toList();
    _curLocal.putIfAbsent(category.name, () => {})[name] = data;
    _writeBack();
  }

  @override
  void removeGlobalPreset(final String name) {
    _curGlobal.remove(name);
    _writeBack();
  }

  @override
  void removeLocalPreset(final ModCategory category, final String name) {
    final localPreset = _curLocal[category.name];
    if (localPreset == null) {
      return;
    }
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
  void setGlobalPreset(final String name) {
    final directives = _curGlobal[name];
    if (directives == null) {
      return;
    }
    _toggleGlobal(directives);
    observerService.forceUpdate();
  }

  @override
  void setLocalPreset(final ModCategory category, final String name) {
    final directives = _curLocal[category.name]?[name];
    if (directives == null) {
      return;
    }
    _toggleLocal(category.path, directives);
    observerService.forceUpdate();
  }

  void _toggleGlobal(final Map<String, List<String>> directives) {
    for (final category in directives.entries) {
      final shouldBeEnabled = category.value;
      final latest2 = appStateService.modRoot.latest;
      if (latest2 == null) {
        return;
      }
      final categoryDir = latest2.pJoin(category.key);
      unawaited(_toggleCategory(categoryDir, shouldBeEnabled));
    }
  }

  void _toggleLocal(
    final String categoryPath,
    final List<String> shouldBeEnabled,
  ) {
    unawaited(_toggleCategory(categoryPath, shouldBeEnabled));
  }

  Future<void> _toggleCategory(
    final String categoryPath,
    final List<String> shouldBeEnabled,
  ) async {
    final latest2 = appStateService.modExecFile.latest;
    if (latest2 == null) {
      return;
    }
    final shaderFixes = latest2.pDirname.pJoin(kShaderFixes);
    final currentEnabled = getUnder<Directory>(categoryPath)
        .where((final e) => e.pIsEnabled)
        .map((final e) => e.pBasename)
        .toList();
    final shouldBeOff =
        currentEnabled.where((final e) => !shouldBeEnabled.contains(e));
    final futures = <Future>[];
    for (final mod in shouldBeOff) {
      final modDir = categoryPath.pJoin(mod);
      final future = disable(
        shaderFixesPath: shaderFixes,
        modPath: modDir,
      );
      futures.add(future);
    }
    final shouldBeOn =
        shouldBeEnabled.where((final e) => !currentEnabled.contains(e));
    for (final mod in shouldBeOn) {
      final modDir = categoryPath.pJoin(mod.pDisabledForm);
      final future = enable(
        shaderFixesPath: shaderFixes,
        modPath: modDir,
      );
      futures.add(future);
    }
    await Future.wait(futures);
  }
}

Map<String, Map<String, List<String>>> _parseMap(
  final Map<String, dynamic> data,
) {
  final parsed = <String, Map<String, List<String>>>{};
  data.forEach((final k, final v) {
    final forEachCategory = _forEachPreset(k, v);
    if (forEachCategory == null) {
      return;
    }
    parsed[k] = forEachCategory;
  });
  return parsed;
}

Map<String, List<String>>? _forEachPreset(final k, final v) {
  if (k is! String) {
    return null;
  }
  if (v is! Map) {
    return null;
  }
  final b = <String, List<String>>{};
  v.forEach((final k, final v) {
    final forEachCategory = _forEachCategory(k, v);
    if (forEachCategory == null) {
      return;
    }
    b[k] = forEachCategory;
  });
  return b;
}

List<String>? _forEachCategory(final k, final v) {
  if (k is! String) {
    return null;
  }
  if (v is! List) {
    return null;
  }
  final c = <String>[];
  for (final e in v) {
    if (e is! String) {
      continue;
    }
    c.add(e);
  }
  return c;
}