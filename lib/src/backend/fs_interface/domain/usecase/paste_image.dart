import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_converter/flutter_image_converter.dart';

import '../../../structure/entity/mod.dart';
import '../repo/fs_interface.dart';

Future<void> pasteImageUseCase(
  final FileSystemInterface fsInterface,
  final Uint8List image,
  final Mod mod,
) async {
  final filePath = fsInterface.pJoin(mod.path, 'preview.png');
  final bytes = await image.pngUint8List;
  await File(filePath).writeAsBytes(bytes);
}
