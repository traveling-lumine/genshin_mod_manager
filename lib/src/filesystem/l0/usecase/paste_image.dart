import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_converter/flutter_image_converter.dart';

import '../../../fs_interface/helper/path_op_string.dart';
import '../../../fs_interface/repo/fs_interface.dart';
import '../entity/mod.dart';

Future<void> pasteImageUseCase(
  final FileSystemInterface fsInterface,
  final Uint8List image,
  final Mod mod,
) async {
  final filePath = mod.path.pJoin('preview.png');
  final bytes = await image.pngUint8List;
  await File(filePath).writeAsBytes(bytes);
}
