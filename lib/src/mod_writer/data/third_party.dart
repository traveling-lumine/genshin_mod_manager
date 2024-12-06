/// Copied from archive package.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:path/path.dart' as path;

String _longestCommonPrefix(final List<String> strings) {
  if (strings.isEmpty) {
    return '';
  }
  var s1 = strings.first;
  var s2 = strings.first;
  for (final s in strings) {
    if (s.compareTo(s1) < 0) {
      s1 = s;
    } else if (s.compareTo(s2) > 0) {
      s2 = s;
    }
  }
  final length = s1.length;
  var i = 0;
  for (; i < length; i++) {
    if (s1.codeUnitAt(i) != s2.codeUnitAt(i)) {
      break;
    }
  }
  return s1.substring(0, i);
}

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

  final longestCommonPrefix =
      _longestCommonPrefix(archive.files.map((e) => e.name).toList());
  final int longestCommonLen;
  if (longestCommonPrefix.endsWith('/') || longestCommonPrefix.endsWith('\\')) {
    longestCommonLen = longestCommonPrefix.length;
  } else {
    longestCommonLen = 0;
  }

  for (final file in archive.files) {
    var name = file.name.substring(longestCommonLen);
    try {
      final decodeString = cp949.decodeString(name);
      if (name == cp949.encodeToString(decodeString)) {
        name = decodeString;
      }
    } on FormatException {
      // do nothing
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
        await link.create(path.normalize(file.nameOfLinkedFile),
            recursive: true);
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
