import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/provider/app_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category.g.dart';

class CategoryModel {
  CategoryModel(this._enabledFirst, this._category) {
    final dir = Directory(_category.path);
    mods = dir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .map(_map);
  }

  final bool _enabledFirst;
  final ModCategory _category;

  late final Stream<List<Mod>> mods;

  List<Mod> _map(final FileSystemEvent event) {
    final dirs = getUnderSync<Directory>(_category.path);
    final modList = dirs.map(_converter).toList()..sort(_sort);
    return modList;
  }

  Mod _converter(final String path) => Mod(
        path: path,
        displayName: path.pEnabledForm.pBasename,
        isEnabled: path.pIsEnabled,
        category: _category,
      );

  int _sort(final Mod a, final Mod b) {
    if (_enabledFirst) {
      final aEnabled = a.isEnabled;
      final bEnabled = a.isEnabled;
      if (aEnabled && !bEnabled) {
        return -1;
      } else if (!aEnabled && bEnabled) {
        return 1;
      }
    }
    final aLower = a.path.pEnabledForm.pBasename.toLowerCase();
    final bLower = b.path.pEnabledForm.pBasename.toLowerCase();
    return aLower.compareTo(bLower);
  }
}

@riverpod
Stream<List<Mod>> categoryWatcher(
  final CategoryWatcherRef ref,
  final ModCategory category,
) {
  final enabledModsFirst = ref.watch(
    appStateNotifierProvider
        .select((final value) => value.showEnabledModsFirst),
  );
  final categoryModel = CategoryModel(enabledModsFirst, category);
  return categoryModel.mods;
}
