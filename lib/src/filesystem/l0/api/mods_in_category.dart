import '../entity/mod.dart';
import 'disposable.dart';

abstract interface class ModsInCategory implements Disposable {
  Stream<List<Mod>> get modsInCategory;
}
