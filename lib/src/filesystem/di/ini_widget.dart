import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/ini.dart';
import '../l1/di/file_event.dart';

part 'ini_widget.g.dart';

@riverpod
class IniLines extends _$IniLines {
  @override
  Stream<List<IniStatement>> build(final IniFile iniFile) {
    final watch = ref.watch(fileEventProvider(path: iniFile.path));
    return watch.stream.asyncMap((final event) {
      final List<String> lines;
      final statements = <IniStatement>[];
      try {
        lines = File(iniFile.path)
            .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true));
      } on PathNotFoundException {
        return statements;
      }
      late IniStatementSection lastSection;
      var metKeySection = false;
      final rawSectionNamePattern = RegExp(r'\[key.*?\]');
      final sectionNamePattern = RegExp(r'\[.*?\]');
      for (final lineIndexed in lines.indexed) {
        final lineNum = lineIndexed.$1;
        final rawLine = lineIndexed.$2.split(';').first;
        final line = rawLine.trim().toLowerCase();

        if (line.startsWith('[')) {
          metKeySection = false;
        }

        final match = rawSectionNamePattern.firstMatch(line)?.group(0);
        if (match != null) {
          final sectionName = sectionNamePattern.firstMatch(rawLine)?.group(0);
          final newSection = IniStatementSection(
            iniFile: iniFile,
            name: sectionName!,
            lineNum: lineNum,
          );
          statements.add(newSection);
          lastSection = newSection;
          metKeySection = true;
        }

        if (!metKeySection) {
          continue;
        }

        if (line.startsWith('key')) {
          statements.add(
            IniStatement.forward(
              lineNum: lineNum,
              section: lastSection,
              value: _getRHS(rawLine),
            ),
          );
        } else if (line.startsWith('back')) {
          statements.add(
            IniStatement.backward(
              lineNum: lineNum,
              section: lastSection,
              value: _getRHS(rawLine),
            ),
          );
        } else if (line.startsWith(r'$') && metKeySection) {
          statements.add(
            IniStatement.variable(
              lineNum: lineNum,
              section: lastSection,
              name: _getLHS(rawLine),
              numCycles: ','.allMatches(rawLine).length + 1,
            ),
          );
        }
      }
      return statements;
    });
  }

  void editIniFile(final int lineNum, final String value) {
    final file = File(iniFile.path);
    final lines =
        file.readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true));
    final lhs = _getLHS(lines[lineNum]);
    lines[lineNum] = '$lhs = $value';
    file.writeAsStringSync(
      lines.join('\n'),
      encoding: const Utf8Codec(allowMalformed: true),
      flush: true,
    );
  }
}

String _getLHS(final String line) {
  final indexOfFirstEqual = line.indexOf('=');
  return line.substring(0, indexOfFirstEqual).trim();
}

String _getRHS(final String line) {
  final indexOfFirstEqual = line.indexOf('=');
  final start = indexOfFirstEqual + 1;
  if (start >= line.length) {
    return '';
  }
  return line.substring(start).trim();
}
