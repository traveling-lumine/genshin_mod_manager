import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/io/mod_switcher.dart';

import 'app_state_service.dart';

class PresetService with ChangeNotifier {
  AppStateService? _appStateService;
  dynamic _internal;
  String? _cache;

  PresetService();

  void update(AppStateService data) {
    _appStateService = data;
    final prevCache = _cache;
    _cache = data.presetData;
    _internal = jsonDecode(data.presetData);
    if (prevCache != _cache) {
      notifyListeners();
    }
  }

  List<String> getGlobalPresets() {
    Map<String, dynamic> global = _internal['global'];
    return global.keys.toList(growable: false);
  }

  List<String> getLocalPresets(String category) {
    Map<String, dynamic> local = _internal['local'];
    try {
      return local[category]!.keys.toList(growable: false);
    } catch (e) {
      return [];
    }
  }

  void addGlobalPreset(String name) {
    Map<String, List<String>> data = {};
    final modRoot = _appStateService!.modRoot;
    final categoryDirs = getDirsUnder(modRoot.toDirectory);
    for (var categoryDir in categoryDirs) {
      final category = categoryDir.pathW.basename.asString;
      data[category] = getDirsUnder(categoryDir)
          .map((e) => e.pathW.basename)
          .where((e) => e.isEnabled)
          .map((e) => e.asString)
          .toList(growable: false);
    }
    _internal['global'][name] = data;
    _writeBack();
  }

  void addLocalPreset(String category, String name) {
    final modRoot = _appStateService!.modRoot;
    final categoryDir = modRoot.join(PathW(category)).toDirectory;
    List<String> data = getDirsUnder(categoryDir)
        .map((e) => e.pathW.basename)
        .where((e) => e.isEnabled)
        .map((e) => e.asString)
        .toList(growable: false);
    try {
      _internal['local'][category][name] = data;
    } catch (e) {
      _internal['local'][category] = {};
      _internal['local'][category][name] = data;
    }
    _writeBack();
  }

  void removeGlobalPreset(String name) {
    Map<String, dynamic> internal = _internal['global'];
    internal.remove(name);
    _writeBack();
  }

  void removeLocalPreset(String category, String name) {
    Map<String, dynamic> internal = _internal['local'];
    try {
      internal[category]?.remove(name);
      _writeBack();
    } catch (e) {
      // do nothing
    }
  }

  void setGlobalPreset(String name) {
    Map<String, dynamic> internal = _internal['global'];
    final directives = internal[name];
    if (directives != null) {
      _toggleGlobal(directives);
    }
  }

  void setLocalPreset(String category, String name) {
    Map<String, dynamic> internal = _internal['local'];
    var internal2 = internal[category];
    final directives = internal2![name];
    if (directives != null) {
      _toggleLocal(category, directives);
    }
  }

  void _toggleGlobal(Map<String, dynamic> directives) {
    final shaderFixes =
        _appStateService!.modExecFile.dirname.join(kShaderFixes);
    for (var category in directives.entries) {
      final categoryDir = _appStateService!.modRoot.join(PathW(category.key));
      final shouldBeEnabled = category.value;
      final currentEnabled = getDirsUnder(categoryDir.toDirectory)
          .map((e) => e.pathW.basename)
          .where((e) => e.isEnabled)
          .map((e) => e.asString)
          .toList(growable: false);

      // two steps: disable all that are enabled but shouldn't be, and enable all that should be enabled but aren't
      // disable first
      final shouldBeOff =
          currentEnabled.where((e) => !shouldBeEnabled.contains(e));
      for (var mod in shouldBeOff) {
        final modDir = categoryDir.join(PathW(mod));
        disable(
          shaderFixesDir: shaderFixes.toDirectory,
          modPathW: modDir,
        );
      }

      // enable second
      final shouldBeOn =
          shouldBeEnabled.where((e) => !currentEnabled.contains(e));
      for (var mod in shouldBeOn) {
        final modDir = categoryDir.join(PathW(mod).disabledForm);
        enable(
          shaderFixesDir: shaderFixes.toDirectory,
          modPathW: modDir,
        );
      }
    }
  }

  void _toggleLocal(String category, List<dynamic> shouldBeEnabled) {
    final shaderFixes =
        _appStateService!.modExecFile.dirname.join(kShaderFixes);
    final categoryDir = _appStateService!.modRoot.join(PathW(category));
    final currentEnabled = getDirsUnder(categoryDir.toDirectory)
        .map((e) => e.pathW.basename)
        .where((e) => e.isEnabled)
        .map((e) => e.asString)
        .toList(growable: false);

    // two steps: disable all that are enabled but shouldn't be, and enable all that should be enabled but aren't
    // disable first
    final shouldBeOff =
        currentEnabled.where((e) => !shouldBeEnabled.contains(e));
    for (var mod in shouldBeOff) {
      final modDir = categoryDir.join(PathW(mod));
      disable(
        shaderFixesDir: shaderFixes.toDirectory,
        modPathW: modDir,
      );
    }

    // enable second
    final shouldBeOn =
        shouldBeEnabled.where((e) => !currentEnabled.contains(e));
    for (var mod in shouldBeOn) {
      final modDir = categoryDir.join(PathW(mod).disabledForm);
      enable(
        shaderFixesDir: shaderFixes.toDirectory,
        modPathW: modDir,
      );
    }
  }

  void _writeBack() {
    _appStateService!.presetData = jsonEncode(_internal);
  }
}
