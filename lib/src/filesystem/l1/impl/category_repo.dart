import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../l0/api/category_repo.dart';
import '../../l0/api/filesystem.dart';
import '../../l0/entity/mod_category.dart';
import '../helper.dart';

class CategoryRepoImpl implements CategoryRepo {
  factory CategoryRepoImpl({
    required final String? modRoot,
    required final Filesystem fs,
  }) {
    if (modRoot == null) {
      return CategoryRepoImpl._(
        categories: Stream.value(<ModCategory>[]),
      );
    }

    final watch = fs.watchDirectory(path: modRoot);

    final getCategories = watch.stream.asyncMap(
      (final event) async => (await pathsUnder<Directory>(modRoot))
          .map((final e) => ModCategory(path: e, name: p.basename(e)))
          .toList()
        ..sort((final a, final b) => compareNatural(a.name, b.name)),
    );
    return CategoryRepoImpl._(
      categories: getCategories,
      onDispose: watch.cancel,
    );
  }

  const CategoryRepoImpl._({
    required this.categories,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<ModCategory>> categories;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }
}
