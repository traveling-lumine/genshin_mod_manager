import '../entity/mod.dart';

abstract interface class ModsInCategory {
  Stream<List<Mod>> get mods;

  Future<void> dispose();
}
