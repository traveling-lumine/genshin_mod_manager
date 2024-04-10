import 'dart:async';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category.g.dart';

class CategoryModel {
  CategoryModel(this._enabledFirst, this._category) {
    final dir = Directory(_category.path);
    _add();
    _subscription = dir
        .watch(
          events: FileSystemEvent.delete |
              FileSystemEvent.create |
              FileSystemEvent.move,
        )
        .listen(_listen);
  }

  final bool _enabledFirst;
  final ModCategory _category;
  late final StreamSubscription<FileSystemEvent> _subscription;

  Stream<List<Mod>> get mods => _mods.stream;
  final _mods = StreamController<List<Mod>>();

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_mods.close());
  }

  void _listen(final FileSystemEvent event) {
    _add();
  }

  void _add() {
    final dirs = getUnderSync<Directory>(_category.path);
    final modList = dirs.map(_converter).toList()..sort(_sort);
    _mods.add(modList);
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
      final bEnabled = b.isEnabled;
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
  final enabledModsFirst = ref.watch(enabledFirstProvider);
  final categoryModel = CategoryModel(enabledModsFirst, category);
  ref.onDispose(categoryModel.dispose);
  return categoryModel.mods;
}
