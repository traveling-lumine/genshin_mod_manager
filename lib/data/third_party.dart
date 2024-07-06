/// Copied from archive package.
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:path/path.dart' as path;

Future<void> extractArchiveToDiskAsync(
  final Archive archive,
  final String outputPath, {
  final bool asyncWrite = false,
  final int? bufferSize,
}) async {
  final futures = <Future<void>>[];
  final outDir = Directory(outputPath);
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }
  for (final file in archive.files) {
    var name = file.name;
    // decode name into Uint8List, try decoding in utf-8, euc-kr.
    // if both fail, use the original name.
    final uint = name.codeUnits;
    try {
      name = const Utf8Decoder().convert(uint);
    } on FormatException {
      try {
        name = cp949.decodeString(name);
      } on FormatException {
        try {
          name = cp949.decode(uint);
        } on FormatException {
          // do nothing
        }
      }
    }
    final filePath = path.join(outputPath, path.normalize(name));

    if ((!file.isFile && !file.isSymbolicLink) ||
        !isWithinOutputPath(outputPath, filePath)) {
      continue;
    }

    if (file.isSymbolicLink) {
      if (!_isValidSymLink(outputPath, file)) {
        continue;
      }
    }

    if (asyncWrite) {
      if (file.isSymbolicLink) {
        final link = Link(filePath);
        await link.create(
          path.normalize(file.nameOfLinkedFile),
          recursive: true,
        );
      } else {
        final output = File(filePath);
        final f = await output.create(recursive: true);
        final fp = await f.open(mode: FileMode.write);
        final bytes = file.content as List<int>;
        await fp.writeFrom(bytes);
        file.clear();
        futures.add(fp.close());
      }
    } else {
      if (file.isSymbolicLink) {
        final link = Link(filePath);
        link.createSync(path.normalize(file.nameOfLinkedFile), recursive: true);
      } else {
        final output = OutputFileStream(filePath, bufferSize: bufferSize);
        try {
          file.writeContent(output);
        } catch (err) {
          //
        }
        await output.close();
      }
    }
  }
  if (futures.isNotEmpty) {
    await Future.wait(futures);
    futures.clear();
  }
}

bool _isValidSymLink(final String outputPath, final ArchiveFile file) {
  final filePath =
      path.dirname(path.join(outputPath, path.normalize(file.name)));
  final linkPath = path.normalize(file.nameOfLinkedFile);
  if (path.isAbsolute(linkPath)) {
    // Don't allow decoding of files outside of the output path.
    return false;
  }
  final absLinkPath = path.normalize(path.join(filePath, linkPath));
  if (!isWithinOutputPath(outputPath, absLinkPath)) {
    // Don't allow decoding of files outside of the output path.
    return false;
  }
  return true;
}
