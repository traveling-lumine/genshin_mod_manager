import 'dart:convert';
import 'dart:io';

import '../entity/ini.dart';

List<IniStatement> parseIniFileUseCase(
  final IniFile iniFile,
) {
  final lines = File(iniFile.path)
      .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true));

  final statements = <IniStatement>[];
  late IniStatementSection lastSection;
  var metKeySection = false;
  final sectionNamePattern = RegExp(r'\[Key.*?\]');
  for (final lineIndexed in lines.indexed) {
    final lineNum = lineIndexed.$1;
    final line = lineIndexed.$2.split(';').first;

    if (line.startsWith('[')) {
      metKeySection = false;
    }

    final match = sectionNamePattern.firstMatch(line)?.group(0);
    if (match != null) {
      final newSection = IniStatementSection(
        iniFile: iniFile,
        name: match,
        lineNum: lineNum,
      );
      statements.add(newSection);
      lastSection = newSection;
      metKeySection = true;
    }

    final lineLower = line.toLowerCase();
    if (lineLower.startsWith('key')) {
      statements.add(
        IniStatement.forward(
          lineNum: lineNum,
          section: lastSection,
          value: _getRHS(line),
        ),
      );
    } else if (lineLower.startsWith('back')) {
      statements.add(
        IniStatement.backward(
          lineNum: lineNum,
          section: lastSection,
          value: _getRHS(line),
        ),
      );
    } else if (line.startsWith(r'$') && metKeySection) {
      statements.add(
        IniStatement.variable(
          lineNum: lineNum,
          section: lastSection,
          name: _getLHS(line),
          numCycles: ','.allMatches(line).length + 1,
        ),
      );
    }
  }
  return statements;
}

void editIniFileUseCase(
  final IniFile iniFile,
  final int lineNum,
  final String value,
) {
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
