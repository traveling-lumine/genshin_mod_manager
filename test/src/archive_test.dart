import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('archive_test.dart', () {
    final archive =
        ZipDecoder().decodeBytes(File('file.zip').readAsBytesSync());
    final newArchive = newMethod(archive);
    File('file.zip').writeAsBytesSync(ZipEncoder().encode(newArchive));
  });
}

Archive newMethod(final Archive archive) {
  final longestCommonPrefix =
      _longestCommonPrefix(archive.files.map((final e) => e.name).toList());
  final int longestCommonLen;
  if (longestCommonPrefix.endsWith('/') || longestCommonPrefix.endsWith(r'\')) {
    longestCommonLen = longestCommonPrefix.length;
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
