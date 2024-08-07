import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart' show ZipDecoder;
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/third_party.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/mod_writer.dart';

/// Exception thrown when a mod zip extraction fails.
class ModZipExtractionException implements Exception {
  /// Default constructor.
  const ModZipExtractionException({required this.data});

  /// The data that failed to extract.
  final Uint8List data;
}

/// Writes mods to [category] directory.
ModWriter createModWriter({required final ModCategory category}) =>
    _ModWriterImpl(category: category);

class _ModWriterImpl implements ModWriter {
  _ModWriterImpl({required this.category});

  final ModCategory category;

  @override
  Future<void> write({
    required final String modName,
    required final Uint8List data,
  }) async {
    final destDirName = await _getNonCollidingModName(category, modName);
    final destDirPath = category.path.pJoin(destDirName);
    await Directory(destDirPath).create(recursive: true);
    try {
      final archive = ZipDecoder().decodeBytes(data);
      await extractArchiveToDiskAsync(archive, destDirPath, asyncWrite: true);
    } on Exception {
      throw ModZipExtractionException(data: data);
    }
  }
}

Future<String> _getNonCollidingModName(
  final ModCategory category,
  final String name,
) =>
    _getNonCollidingName(category, name.pEnabledForm);

Future<String> _getNonCollidingName(
  final ModCategory category,
  final String destDirName,
) async {
  final enabledFormDirNames = getUnder<Directory>(category.path)
      .map((final e) => e.pDisabledForm.pBasename)
      .toSet();
  var counter = 0;
  var noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  return noCollisionDestDirName;
}
