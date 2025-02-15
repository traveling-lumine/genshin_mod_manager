import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/ini.dart';
import '../l1/di/filesystem.dart';

part 'ini_widget.g.dart';

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

@riverpod
class IniLines extends _$IniLines {
  @override
  Stream<List<IniStatement>> build(final IniFile iniFile) {
    final fs = ref.watch(filesystemProvider);
    final watcher = fs.watchFile(path: iniFile.path);
    ref.onDispose(watcher.cancel);
    return watcher.stream.asyncMap((final event) {
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
          final numCycles = ','.allMatches(rawLine).length + 1;
          if (statements.isEmpty) {
            statements.add(
              IniStatement.variable(
                lineNum: lineNum,
                section: lastSection,
                name: _getLHS(rawLine),
                numCycles: numCycles,
              ),
            );
          } else {
            final lastStatement = statements.last;
            if (lastStatement is! IniStatementVariable) {
              statements.add(
                IniStatement.variable(
                  lineNum: lineNum,
                  section: lastSection,
                  name: _getLHS(rawLine),
                  numCycles: numCycles,
                ),
              );
            } else if (lastStatement.numCycles != numCycles) {
              statements.add(
                IniStatement.variable(
                  lineNum: lineNum,
                  section: lastSection,
                  name: _getLHS(rawLine),
                  numCycles: numCycles,
                ),
              );
            }
          }
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
