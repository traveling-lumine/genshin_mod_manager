import 'dart:typed_data';

typedef ModWriter = Future<void> Function({
  required String modName,
  required Uint8List data,
});
