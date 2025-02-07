abstract interface class FolderIconRepo {
  Stream<String?> get stream;
  Future<void> dispose();
}
