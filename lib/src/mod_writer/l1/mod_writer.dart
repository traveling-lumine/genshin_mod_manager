import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:cp949_codec/cp949_codec.dart';

import '../../filesystem/l1/impl/fsops.dart';
import '../../filesystem/l1/impl/path_op_string.dart';

Archive collapseArchiveFolder(final Archive archive) {
  final longestCommonPrefix1 =
      longestCommonPrefix(archive.files.map((final e) => e.name).toList());
  final int longestCommonLen;
  if (longestCommonPrefix1.endsWith('/') ||
      longestCommonPrefix1.endsWith(r'\')) {
    longestCommonLen = longestCommonPrefix1.length;
  } else {
    longestCommonLen = 0;
  }
  if (longestCommonLen == 0) {
    return archive;
  }
  final newArchive = Archive();
  for (final entry in archive) {
    var name = entry.name.substring(longestCommonLen);
    if (name.isEmpty) {
      continue;
    }
    try {
      final decodeString = cp949.decodeString(name);
      if (name == cp949.encodeToString(decodeString)) {
        name = decodeString;
      }
    } on FormatException {
      // do nothing
    }
    entry.name = name;
    newArchive.add(entry);
  }
  return newArchive;
}

Future<String> getNonCollidingModName(
  final String categoryPath,
  final String name,
) {
  final sanitizedName = sanitizeString(name);
  return getNonCollidingName(categoryPath, sanitizedName.pEnabledForm);
}

Future<String> getNonCollidingName(
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

String longestCommonPrefix(final List<String> strings) {
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

String sanitizeString(final String name) {
  final sanitizedName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  return sanitizedName.trim();
}

/// Exception thrown when a mod zip extraction fails.
class ModZipExtractionException implements Exception {
  /// Default constructor.
  const ModZipExtractionException({required this.data});

  /// The data that failed to extract.
  final Uint8List data;
}
