import '../entity/mod.dart';

abstract interface class ModsInCategory {
  Stream<List<Mod>> get modsUnsorted;

  Future<void> dispose();
}
