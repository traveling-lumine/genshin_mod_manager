/// Copied from archive package.
library;

import 'dart:io';

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
  int? bufferSize,
}) async {
  final futures = <Future<void>>[];
  final outDir = Directory(outputPath);
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final longestCommonPrefix =
      _longestCommonPrefix(archive.files.map((final e) => e.name).toList());
  final int longestCommonLen;
  if (longestCommonPrefix.endsWith('/') || longestCommonPrefix.endsWith(r'\')) {
    longestCommonLen = longestCommonPrefix.length;
  } else {
    longestCommonLen = 0;
  }

  for (final entry in archive) {
    var name = entry.name.substring(longestCommonLen);
    try {
      final decodeString = cp949.decodeString(name);
      if (name == cp949.encodeToString(decodeString)) {
        name = decodeString;
      }
    } on FormatException {
      // do nothing
    }

    final filePath = path.normalize(path.join(outputPath, name));

    if ((entry.isDirectory && !entry.isSymbolicLink) ||
        !_isWithinOutputPath(outputPath, filePath)) {
      continue;
    }

    if (entry.isSymbolicLink) {
      if (!_isValidSymLink(outputPath, entry)) {
        continue;
      }

      final link = Link(filePath);
      await link.create(
        path.normalize(entry.symbolicLink ?? ''),
        recursive: true,
      );
      continue;
    }

    if (entry.isDirectory) {
      await Directory(filePath).create(recursive: true);
      continue;
    }

    final file = entry;

    bufferSize ??= OutputFileStream.kDefaultBufferSize;
    final fileSize = file.size;
    final fileBufferSize = fileSize < bufferSize ? fileSize : bufferSize;
    final output = OutputFileStream(filePath, bufferSize: fileBufferSize);
    try {
      file.writeContent(output);
    } catch (err) {
      //
    }
    await output.close();
  }

  if (futures.isNotEmpty) {
    await Future.wait(futures);
    futures.clear();
  }
}

bool _isValidSymLink(final String outputPath, final ArchiveFile file) {
  final filePath =
      path.dirname(path.join(outputPath, path.normalize(file.name)));
  final linkPath = path.normalize(file.symbolicLink ?? '');
  if (path.isAbsolute(linkPath)) {
    // Don't allow decoding of files outside of the output path.
    return false;
  }
  final absLinkPath = path.normalize(path.join(filePath, linkPath));
  if (!_isWithinOutputPath(outputPath, absLinkPath)) {
    // Don't allow decoding of files outside of the output path.
    return false;
  }
  return true;
}

bool _isWithinOutputPath(final String outputDir, final String filePath) =>
    path.isWithin(
      path.canonicalize(outputDir),
      path.canonicalize(filePath),
    );
