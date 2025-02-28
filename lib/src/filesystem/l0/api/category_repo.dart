import '../entity/mod_category.dart';
import 'disposable.dart';

abstract interface class CategoryRepo implements Disposable {
  Stream<List<ModCategory>> get categories;
}
