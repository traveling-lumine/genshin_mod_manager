import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/structure/entity/mod_category.dart';
import 'package:genshin_mod_manager/src/structure/usecase/collect_categories.dart';

void main() {
  setUp(() {
    // Create a temporary directory, which dir a b are in
    Directory('dir').createSync();
    Directory('dir/a').createSync();
    Directory('dir/b').createSync();
  });
  tearDown(() {
    // Delete the temporary directory
    Directory('dir').deleteSync(recursive: true);
  });
  test('collectCategoriesUseCase', () {
    final allDirs = collectCategoriesUseCase(modRoot: 'dir');
    expect(allDirs, hasLength(2));
    expect(
      allDirs,
      orderedEquals([
        ModCategory(path: r'dir\a', name: 'a'),
        ModCategory(path: 'dir/b', name: 'b'),
      ]),
    );
  });
}
