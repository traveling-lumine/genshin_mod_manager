import '../entity/mod_category.dart';

abstract interface class CategoriesRepo {
  Stream<List<ModCategory>> get categories;
  Future<void> dispose();
}
