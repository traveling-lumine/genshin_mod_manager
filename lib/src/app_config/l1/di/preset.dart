import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../filesystem/l0/entity/mod_category.dart';
import '../../../filesystem/l1/impl/fsops.dart';
import '../../../filesystem/l1/impl/mod_switcher.dart';
import '../../../filesystem/l1/impl/path_op_string.dart';
import '../../l0/entity/entries.dart';
import '../../l0/entity/preset.dart';
import '../../l0/usecase/change_preset.dart';
import 'app_config.dart';
import 'app_config_facade.dart';
import 'app_config_persistent_repo.dart';

part 'preset.g.dart';

Future<void> _toggleCategory(
  final String categoryPath,
  final List<String> shouldBeEnabled,
  final Ref<List<String>> ref,
) async {
  final modExecFile = ref
      .read(appConfigFacadeProvider)
      .obtainValue(games)
      .currentGameConfig
      .modExecFile;
  if (modExecFile == null) {
    return;
  }
  final shaderFixes = modExecFile.pDirname.pJoin(kShaderFixes);
  final currentEnabled = getUnderSync<Directory>(categoryPath)
      .where((final e) => e.pIsEnabled)
      .map((final e) => e.pBasename)
      .toList();
  final shouldBeOff =
      currentEnabled.where((final e) => !shouldBeEnabled.contains(e));
  final futures = <Future<void>>[];
  for (final mod in shouldBeOff) {
    final modDir = categoryPath.pJoin(mod);
    final future = disable(shaderFixesPath: shaderFixes, modPath: modDir);
    futures.add(future);
  }
  final shouldBeOn =
      shouldBeEnabled.where((final e) => !currentEnabled.contains(e));
  for (final mod in shouldBeOn) {
    final modDir = categoryPath.pJoin(mod.pDisabledForm);
    final future = enable(shaderFixesPath: shaderFixes, modPath: modDir);
    futures.add(future);
  }
  await Future.wait(futures);
}

@riverpod
class GlobalPresetNotifier extends _$GlobalPresetNotifier
    implements PresetNotifier {
  @override
  List<String> build() {
    final presetData = ref.watch(
      appConfigFacadeProvider.select(
        (final value) => value.obtainValue(games).currentGameConfig.presetData,
      ),
    );
    return presetData.global.keys.toList();
  }

  @override
  void renamePreset({
    required final String oldName,
    required final String newName,
  }) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    final globalPresets = presetData.global;
    final oldData = globalPresets[oldName];
    if (oldData == null) {
      return;
    }
    if (globalPresets.containsKey(newName)) {
      return;
    }
    final res = presetData.copyWith(
      global: {
        for (final e in globalPresets.entries)
          if (e.key == oldName) newName: e.value else e.key: e.value,
      },
    );
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
  }

  @override
  void setPreset(final String name) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    final data = presetData.global[name];
    if (data == null) {
      return;
    }
    final directives = {
      for (final e in data.bundledPresets.entries) e.key: e.value.mods,
    };
    _toggleGlobal(directives);
  }

  void _toggleGlobal(final Map<String, List<String>> directives) {
    for (final category in directives.entries) {
      final shouldBeEnabled = category.value;
      final latest2 = ref
          .read(appConfigFacadeProvider)
          .obtainValue(games)
          .currentGameConfig
          .modRoot;
      if (latest2 == null) {
        return;
      }
      final categoryDir = latest2.pJoin(category.key);
      unawaited(_toggleCategory(categoryDir, shouldBeEnabled, ref));
    }
  }
}

@riverpod
class LocalPresetNotifier extends _$LocalPresetNotifier
    implements PresetNotifier {
  @override
  List<String> build(final ModCategory category) {
    final presetData = ref.watch(
      appConfigFacadeProvider.select(
        (final value) => value.obtainValue(games).currentGameConfig.presetData,
      ),
    );
    return presetData.local[category.name]?.bundledPresets.keys.toList() ?? [];
  }

  @override
  void renamePreset({
    required final String oldName,
    required final String newName,
  }) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    final localPresets = presetData.local;
    final categoryPresets = localPresets[category.name];
    if (categoryPresets == null) {
      return;
    }
    final modString = {...categoryPresets.bundledPresets};
    final oldMods = modString.remove(oldName);
    if (oldMods == null) {
      return;
    }
    if (modString.containsKey(newName)) {
      return;
    }
    modString[newName] = oldMods;
    _updatePreset(modString, localPresets, presetData);
  }

  @override
  void setPreset(final String name) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    final directives =
        presetData.local[category.name]?.bundledPresets[name]?.mods;
    if (directives == null) {
      return;
    }
    _toggleLocal(category.path, directives);
  }

  void _toggleLocal(
    final String categoryPath,
    final List<String> shouldBeEnabled,
  ) {
    unawaited(_toggleCategory(categoryPath, shouldBeEnabled, ref));
  }

  void _updatePreset(
    final Map<String, PresetList> modString,
    final Map<String, PresetListMap> localPresets,
    final PresetData presetData,
  ) {
    final newCategoryPresets = PresetListMap(bundledPresets: modString);
    final newLocalPresets = {...localPresets}..[category.name] =
        newCategoryPresets;
    final res = presetData.copyWith(local: newLocalPresets);
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
  }
}

abstract interface class PresetNotifier {
  void renamePreset({
    required final String oldName,
    required final String newName,
  });

  void setPreset(final String name);
}
