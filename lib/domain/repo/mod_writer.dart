import 'dart:typed_data';

abstract interface class ModWriter {
  Future<void> write({
    required String modName,
    required Uint8List data,
  });
}
