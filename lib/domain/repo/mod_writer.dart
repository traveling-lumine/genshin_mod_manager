import 'dart:typed_data';

abstract interface class ModWriter {
  Future<void> write({
    required final String modName,
    required final Uint8List data,
  });
}
