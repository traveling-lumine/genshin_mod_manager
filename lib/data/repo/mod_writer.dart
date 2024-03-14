import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/mod_writer.dart';

ModWriter createModWriter({
  required final ModCategory category,
}) => _ModWriterImpl(
    category: category,
  );

class _ModWriterImpl implements ModWriter {

  _ModWriterImpl({
    required this.category,
  });
  final ModCategory category;

  @override
  Future<void> write({
    required final String modName,
    required final Uint8List data,
  }) async {
    final destDirName =
        (await _getNonCollidingModName(category, modName)).pDisabledForm;
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

class ModZipExtractionException implements Exception {

  const ModZipExtractionException({required this.data});
  final Uint8List data;
}

Future<String> _getNonCollidingModName(
  final ModCategory category,
  final String name,
) async {
  final enabledModName = _getEnabledNameRecursive(name);
  return await _getNonCollidingName(category, enabledModName);
}

String _getEnabledNameRecursive(final String name) {
  var destDirName = name.pEnabledForm;
  while (!destDirName.pIsEnabled) {
    destDirName = destDirName.pEnabledForm;
  }
  return destDirName;
}

Future<String> _getNonCollidingName(
  final ModCategory category,
  final String destDirName,
) async {
  final enabledFormDirNames = (await getUnder<Directory>(category.path))
      .map((final e) => e.path.pBasename.pEnabledForm)
      .toSet();
  var counter = 0;
  var noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  return noCollisionDestDirName;
}
