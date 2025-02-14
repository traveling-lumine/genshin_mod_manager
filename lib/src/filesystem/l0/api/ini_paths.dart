abstract interface class IniPathsRepo {
  Stream<List<String>> get stream;
  Future<void> dispose();
}
