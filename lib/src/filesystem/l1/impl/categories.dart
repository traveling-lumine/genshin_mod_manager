import 'dart:io';

import 'package:collection/collection.dart';

import '../../l0/api/categories.dart';
import '../../l0/api/filesystem.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod_category.dart';
import 'fsops.dart';
import 'path_op_string.dart';

class CategoriesRepoImpl implements CategoriesRepo {
  factory CategoriesRepoImpl({
    required final String? modRoot,
    required final Filesystem fs,
  }) {
    if (modRoot == null) {
      return CategoriesRepoImpl._(
        categories: Stream.value(<ModCategory>[]).asBroadcastStream(),
      );
    }
    final watch = fs.watchDirectory(path: modRoot);
    final categories =
        watch.stream.asyncMap((final event) async => streamMap(modRoot));
    return CategoriesRepoImpl._(watcher: watch, categories: categories);
  }
  const CategoriesRepoImpl._({
    required this.categories,
    this.watcher,
  });
  final Watcher? watcher;
  @override
  final Stream<List<ModCategory>> categories;
  @override
  Future<void> dispose() async {
    await watcher?.cancel();
  }

  static Future<List<ModCategory>> streamMap(final String modRoot) async =>
      (await getUnder<Directory>(modRoot))
          .map((final e) => ModCategory(path: e, name: e.pBasename))
          .toList()
        ..sort((final a, final b) => compareNatural(a.name, b.name));
}
