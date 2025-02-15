import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../filesystem/l0/entity/mod_category.dart';
import '../../../filesystem/l1/impl/fsops.dart';
import '../../../filesystem/l1/impl/mod_switcher.dart';
import '../../../filesystem/l1/impl/path_op_string.dart';
import '../../l0/entity/entries.dart';
import '../../l0/usecase/change_preset.dart';
import '../../l0/entity/preset.dart';
import 'app_config.dart';
import 'app_config_facade.dart';
import 'app_config_persistent_repo.dart';

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
      appConfigFacadeProvider.select(
        (final value) => value.obtainValue(games).currentGameConfig.presetData,
      ),
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

    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;

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
      final newState = changePresetUseCase(
        appConfigFacade: ref.read(appConfigFacadeProvider),
        value: res,
        appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      );
      ref.read(appConfigCProvider.notifier).setData(newState);
    } else {
      final bundledPreset =
          PresetListMap(bundledPresets: {name: presetTargetData});
      final res = PresetData(global: {}, local: {category.name: bundledPreset});
      final newState = changePresetUseCase(
        appConfigFacade: ref.read(appConfigFacadeProvider),
        value: res,
        appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      );
      ref.read(appConfigCProvider.notifier).setData(newState);
    }
  }

  @override
  void setPreset(final String name) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    final directives =
        presetData?.local[category.name]?.bundledPresets[name]?.mods;
    if (directives == null) {
      return;
    }
    _toggleLocal(category.path, directives);
  }

  @override
  void removePreset(final String name) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
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
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
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
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
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
      appConfigFacadeProvider.select(
        (final value) => value.obtainValue(games).currentGameConfig.presetData,
      ),
    );
    return presetData?.global.keys.toList() ?? [];
  }

  @override
  void addPreset(final String name) {
    final rootPath = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .modRoot;
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
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    if (presetData != null) {
      final newGlobalPresets = {...presetData.global}..[name] = bpd;
      final res = presetData.copyWith(global: newGlobalPresets);
      final newState = changePresetUseCase(
        appConfigFacade: ref.read(appConfigFacadeProvider),
        value: res,
        appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      );
      ref.read(appConfigCProvider.notifier).setData(newState);
    } else {
      final res = PresetData(global: {name: bpd}, local: {});
      final newState = changePresetUseCase(
        appConfigFacade: ref.read(appConfigFacadeProvider),
        value: res,
        appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      );
      ref.read(appConfigCProvider.notifier).setData(newState);
    }
  }

  @override
  void setPreset(final String name) {
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
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
    final presetData = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .presetData;
    if (presetData == null) {
      return;
    }
    final res =
        presetData.copyWith(global: {...presetData.global}..remove(name));
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
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
    final newState = changePresetUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      value: res,
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
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
