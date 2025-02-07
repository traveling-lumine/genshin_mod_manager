abstract interface class ModPreviewPathRepo {
  Stream<String?> get stream;
  Future<void> dispose();
}
