// Should catch all errors/exceptions
// ignore_for_file: avoid_catches_without_on_clauses

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

void registerErrorHandlers() {
  FlutterError.onError = _onErrorHandler;
  ErrorWidget.builder = _errorWidgetBuilder;
}

void _onErrorHandler(final FlutterErrorDetails details) {
  FlutterError.presentError(details);
  final now = DateTime.now().toUtc().toIso8601String();
  final message = _errorToString(details);
  final stackTrace = writeStacktrace(details);
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

Widget _errorWidgetBuilder(final FlutterErrorDetails details) => Center(
      child: SelectableText(
        _errorToString(details),
        style: TextStyle(color: Colors.red.darker),
      ),
    );

String writeStacktrace(final FlutterErrorDetails details) {
  try {
    final stack = details.stack;
    if (stack == null) {
      return 'Stack trace not available';
    }
    final stackTrace = stack.toString();
    return elideLines(stackTrace);
  } catch (e) {
    return 'Error writing stack trace';
  }
}

String elideLines(final String stackTrace) {
  final lines = <String>[];
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
