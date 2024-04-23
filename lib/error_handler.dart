import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

/// Registers error handlers for the application.
void registerErrorHandlers() {
  FlutterError.onError = _onErrorHandler;
  ErrorWidget.builder = _errorWidgetBuilder;
}

void _onErrorHandler(final details) {
  final now = DateTime.now().toUtc().toIso8601String();
  final message = _errorToString(details);
  final stackTrace = _writeStacktrace(details);
  try {
    File('error.log').writeAsStringSync(
      '[$now]\n'
      'Message:\n'
      '$message\n'
      'Stacktrace:\n'
      '$stackTrace\n'
      '\n',
      mode: FileMode.append,
    );
  } catch (e) {
    // print('Error writing to error log: $e');
  }
}

Widget _errorWidgetBuilder(final details) => Center(
      child: SelectableText(
        _errorToString(details),
        style: TextStyle(color: Colors.red.darker),
      ),
    );

String _writeStacktrace(final FlutterErrorDetails details) {
  try {
    final stackTrace = details.stack.toString();
    return _elideLines(stackTrace);
  } catch (e) {
    return 'Stack trace not available';
  }
}

String _elideLines(final String stackTrace) {
  // only choose lines that include genshin_mod_manager.
  // Lines that don't include it are shrunk to ...
  final lines = [];
  var elidedLines = 0;
  for (final line in stackTrace.split('\n')) {
    if (!line.contains('genshin_mod_manager')) {
      elidedLines++;
      continue;
    }
    if (elidedLines > 0) {
      lines.add('... ($elidedLines lines elided)');
      elidedLines = 0;
    }
    lines.add(line);
  }
  if (elidedLines > 0) {
    lines.add('... ($elidedLines lines elided)');
  }
  return lines.join('\n');
}

String _errorToString(final FlutterErrorDetails details) {
  try {
    return details.exception.toString();
  } catch (e) {
    try {
      return details.toString();
    } catch (e) {
      return 'An error occurred';
    }
  }
}

// ignore_for_file: avoid_catches_without_on_clauses
