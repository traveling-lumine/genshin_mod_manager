import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../l0/api/ini_file_repo.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/ini.dart';

Future<void> _edit(
  final IniFile iniFile2,
  final int lineNum,
  final String value,
) async {
  final file = File(iniFile2.path);
  final lines =
      await file.readAsLines(encoding: const Utf8Codec(allowMalformed: true));
  final lhs = _getLHS(lines[lineNum]);
  lines[lineNum] = '$lhs = $value';
  await file.writeAsString(
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

Future<List<IniStatement>> _getValue(final IniFile iniFile) async {
  final List<String> lines;
  final statements = <IniStatement>[];
  try {
    lines = await File(iniFile.path)
        .readAsLines(encoding: const Utf8Codec(allowMalformed: true));
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
}

class IniFileRepoImpl implements IniFileRepo {
  factory IniFileRepoImpl({
    required final Watcher watcher,
    required final IniFile iniFile,
  }) {
    final streamController = StreamController<List<IniStatement>>();
    StreamSubscription<List<IniStatement>>? subscription;

    unawaited(
      _getValue(iniFile).then<void>(
        (final value) {
          if (streamController.isClosed) {
            return;
          }
          streamController.add(value);
          subscription = watcher.stream
              .asyncMap((final event) => _getValue(iniFile))
              .listen(
                streamController.add,
                onError: streamController.addError,
                onDone: streamController.close,
              );
        },
      ).onError(streamController.addError),
    );

    return IniFileRepoImpl._(
      iniFile: iniFile,
      statements: streamController.stream,
      onDispose: () async {
        await subscription?.cancel();
        await streamController.close();
      },
    );
  }

  const IniFileRepoImpl._({
    required this.iniFile,
    required this.statements,
    this.onDispose,
  });

  final IniFile iniFile;

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<IniStatement>> statements;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }

  @override
  Future<void> edit({
    required final int lineNum,
    required final String value,
  }) async {
    await _edit(iniFile, lineNum, value);
  }
}
