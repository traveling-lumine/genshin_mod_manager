import 'dart:async';

import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';

abstract interface class CategoryWatcher {
  Stream<List<Mod>> get mods;
  Future<void> dispose();
}

abstract interface class RootWatcher {
  Stream<List<ModCategory>> get categories;
  void refresh();
  void dispose();
}
