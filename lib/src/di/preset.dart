import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/fs_interface/helper/fsops.dart';
import '../backend/fs_interface/helper/mod_switcher.dart';
import '../backend/fs_interface/helper/path_op_string.dart';
import '../backend/storage/domain/entity/preset.dart';
import '../backend/structure/entity/mod_category.dart';
import 'app_state/game_config.dart';

part 'preset.g.dart';

abstract interface class PresetNotifier {
  void addPreset(final String name);

  void setPreset(final String name);

  void removePreset(final String name);

  void renamePreset({
    required final String oldName,
    required final String newName,
  });
}

@riverpod
class LocalPresetNotifier extends _$LocalPresetNotifier
    implements PresetNotifier {
  @override
  List<String> build(final ModCategory category) {
    final presetData = ref.watch(
      gameConfigNotifierProvider.select((final value) => value.presetData),
    );
    return presetData?.local[category.name]?.bundledPresets.keys.toList() ?? [];
  }

  @override
  void addPreset(final String name) {
    final presetTargetData = PresetList(
      mods: getUnderSync<Directory>(category.path)
          .where((final e) => e.pIsEnabled)
          .map((final e) => e.pBasename)
          .toList(),
    );

    final presetData = ref.read(gameConfigNotifierProvider).presetData;

    if (presetData != null) {
      final localPresets = presetData.local;
      final categoryPresets = localPresets[category.name];
      final Map<String, PresetList> modString;
      if (categoryPresets != null) {
        modString = {...categoryPresets.bundledPresets}..[name] =
            presetTargetData;
      } else {
        modString = {name: presetTargetData};
      }
      final newCategoryPresets = PresetListMap(bundledPresets: modString);
      final newLocalPresets = {...localPresets}..[category.name] =
          newCategoryPresets;
      final res = presetData.copyWith(local: newLocalPresets);
      ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
    } else {
      final bundledPreset =
          PresetListMap(bundledPresets: {name: presetTargetData});
      final res = PresetData(global: {}, local: {category.name: bundledPreset});
      ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
    }
  }

  @override
  void setPreset(final String name) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    final directives =
        presetData?.local[category.name]?.bundledPresets[name]?.mods;
    if (directives == null) {
      return;
    }
    _toggleLocal(category.path, directives);
  }

  @override
  void removePreset(final String name) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData == null) {
      return;
    }
    final localPresets = presetData.local;
    final categoryPresets = localPresets[category.name];
    if (categoryPresets == null) {
      return;
    }
    final modString = {...categoryPresets.bundledPresets}..remove(name);
    final newCategoryPresets = PresetListMap(bundledPresets: modString);
    final newLocalPresets = {...localPresets}..[category.name] =
        newCategoryPresets;
    final res = presetData.copyWith(local: newLocalPresets);
    ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
  }

  @override
  void renamePreset({
    required final String oldName,
    required final String newName,
  }) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData == null) {
      return;
    }
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
    final newCategoryPresets = PresetListMap(bundledPresets: modString);
    final newLocalPresets = {...localPresets}..[category.name] =
        newCategoryPresets;
    final res = presetData.copyWith(local: newLocalPresets);
    ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
  }

  void _toggleLocal(
    final String categoryPath,
    final List<String> shouldBeEnabled,
  ) {
    unawaited(_toggleCategory(categoryPath, shouldBeEnabled, ref));
  }
}

@riverpod
class GlobalPresetNotifier extends _$GlobalPresetNotifier
    implements PresetNotifier {
  @override
  List<String> build() {
    final presetData = ref.watch(
      gameConfigNotifierProvider.select((final value) => value.presetData),
    );
    return presetData?.global.keys.toList() ?? [];
  }

  @override
  void addPreset(final String name) {
    final rootPath = ref.read(gameConfigNotifierProvider).modRoot;
    if (rootPath == null) {
      return;
    }
    final bpd = PresetListMap(
      bundledPresets: {
        for (final categoryDir in getUnderSync<Directory>(rootPath))
          categoryDir.pBasename: PresetList(
            mods: getUnderSync<Directory>(categoryDir)
                .map((final e) => e.pBasename)
                .where((final e) => e.pIsEnabled)
                .toList(),
          ),
      },
    );
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData != null) {
      final newGlobalPresets = {...presetData.global}..[name] = bpd;
      final res = presetData.copyWith(global: newGlobalPresets);
      ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
    } else {
      final res = PresetData(global: {name: bpd}, local: {});
      ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
    }
  }

  @override
  void setPreset(final String name) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData == null) {
      return;
    }
    final data = presetData.global[name];
    if (data == null) {
      return;
    }
    final directives = {
      for (final e in data.bundledPresets.entries) e.key: e.value.mods,
    };
    _toggleGlobal(directives);
  }

  @override
  void removePreset(final String name) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData == null) {
      return;
    }
    final res =
        presetData.copyWith(global: {...presetData.global}..remove(name));
    ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
  }

  @override
  void renamePreset({
    required final String oldName,
    required final String newName,
  }) {
    final presetData = ref.read(gameConfigNotifierProvider).presetData;
    if (presetData == null) {
      return;
    }
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
    ref.read(gameConfigNotifierProvider.notifier).changePresetData(res);
  }

  void _toggleGlobal(final Map<String, List<String>> directives) {
    for (final category in directives.entries) {
      final shouldBeEnabled = category.value;
      final latest2 = ref.read(gameConfigNotifierProvider).modRoot;
      if (latest2 == null) {
        return;
      }
      final categoryDir = latest2.pJoin(category.key);
      unawaited(_toggleCategory(categoryDir, shouldBeEnabled, ref));
    }
  }
}

Future<void> _toggleCategory(
  final String categoryPath,
  final List<String> shouldBeEnabled,
  final AutoDisposeNotifierProviderRef<List<String>> ref,
) async {
  final modExecFile = ref.read(gameConfigNotifierProvider).modExecFile;
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
