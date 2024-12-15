import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' show ZipDecoder;

import '../../fs_interface/helper/fsops.dart';
import '../../fs_interface/helper/path_op_string.dart';
import '../domain/mod_writer.dart';
import 'third_party.dart';

/// Exception thrown when a mod zip extraction fails.
class ModZipExtractionException implements Exception {
  /// Default constructor.
  const ModZipExtractionException({required this.data});

  /// The data that failed to extract.
  final Uint8List data;
}

/// Writes mods to [categoryPath] directory.
ModWriter createModWriter({required final String categoryPath}) => ({
      required final modName,
      required final data,
    }) async {
      final destDirName = await _getNonCollidingModName(categoryPath, modName);
      final destDirPath = categoryPath.pJoin(destDirName);
      try {
        final archive = ZipDecoder().decodeBytes(data);
        await extractArchiveToDiskAsync(archive, destDirPath);
      } on Exception {
        throw ModZipExtractionException(data: data);
      }
    };

Future<String> _getNonCollidingModName(
  final String categoryPath,
  final String name,
) {
  final sanitizedName = sanitizeString(name);
  return _getNonCollidingName(categoryPath, sanitizedName.pEnabledForm);
}

String sanitizeString(final String name) {
  final sanitizedName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  return sanitizedName.trim();
}

Future<String> _getNonCollidingName(
  final String categoryPath,
  final String destDirName,
) async {
  final enabledFormDirNames = getUnderSync<Directory>(categoryPath)
      .map((final e) => e.pEnabledForm.pBasename)
      .toSet();
  var counter = 0;
  var noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  return noCollisionDestDirName;
}
