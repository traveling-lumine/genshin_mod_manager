import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/mod_writer.dart';

ModWriter createModWriter({
  required ModCategory category,
}) {
  return _ModWriterImpl(
    category: category,
  );
}

class _ModWriterImpl implements ModWriter {
  final ModCategory category;

  _ModWriterImpl({
    required this.category,
  });

  @override
  Future<void> write({
    required String modName,
    required Uint8List data,
  }) async {
    final destDirName =
        _getNonCollidingModName(category, modName).pDisabledForm;
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
  final Uint8List data;

  const ModZipExtractionException({required this.data});
}

String _getNonCollidingModName(ModCategory category, String name) {
  final enabledModName = _getEnabledNameRecursive(name);
  return _getNonCollidingName(category, enabledModName);
}

String _getEnabledNameRecursive(String name) {
  String destDirName = name.pEnabledForm;
  while (!destDirName.pIsEnabled) {
    destDirName = destDirName.pEnabledForm;
  }
  return destDirName;
}

String _getNonCollidingName(ModCategory category, String destDirName) {
  final enabledFormDirNames = getFSEUnder<Directory>(category.path)
      .map((e) => e.path.pBasename.pEnabledForm)
      .toSet();
  int counter = 0;
  String noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  return noCollisionDestDirName;
}
