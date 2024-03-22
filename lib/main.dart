import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/ui/router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

const _minWindowSize = Size(600, 600);

void main(final List<String> args) async {
  print('Starting app with args: $args');
  await _initialize();
  if (!kDebugMode) {
    _registerErrorHandlers();
  }
  runApp(ProviderScope(child: MyApp()));
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      minimumSize: _minWindowSize,
    ),
  );
}

void _registerErrorHandlers() {
  FlutterError.onError = (final details) {
    final now = DateTime.now().toUtc().toIso8601String();
    final message = _errorToString(details);
    final stackTrace = _writeStacktrace(details);
    try {
      File('error.log').writeAsStringSync(
        '[$now]\nMessage:\n$message\nStacktrace:\n$stackTrace\n\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // print('Error writing to error log: $e');
    }
  };

  ErrorWidget.builder = (final details) => Center(
        child: SelectableText(
          _errorToString(details),
          style: TextStyle(color: Colors.red.darker),
        ),
      );
}

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
    if (line.contains('genshin_mod_manager')) {
      if (elidedLines > 0) {
        lines.add('... ($elidedLines lines elided)');
        elidedLines = 0;
      }
      lines.add(line);
      elidedLines = 0;
    } else {
      elidedLines++;
    }
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
