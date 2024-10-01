import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/error_handler.dart';

void main() {
  test('elideLines', () {
    const stackTrace = '''
#0      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)
#1      _onErrorHandler (package:fluent_ui/src/error_handler.dart:22:3)
#2      FlutterError.onError (package:flutter/src/foundation/error.dart:209:5)
#3      _runApp (package:fluent_ui/src/app.dart:19:3)''';
    final elided = elideLines(stackTrace);
    expect(
      elided,
      '''
#0      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)
... (3 lines elided)''',
    );
  });
  group('writeStacktrace', () {
    late FlutterErrorDetails details;
    setUp(() {
      details = FlutterErrorDetails(
        stack: StackTrace.fromString('''
#0      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)
#1      _onErrorHandler (package:fluent_ui/src/error_handler.dart:22:3)
#2      FlutterError.onError (package:flutter/src/foundation/error.dart:209:5)
#3      _runApp (package:fluent_ui/src/app.dart:19:3)'''),
        exception: Exception('Test exception'),
      );
    });
    test('should return stack trace', () {
      final stackTrace = writeStacktrace(details);
      expect(
        stackTrace,
        elideLines(details.stack.toString()),
      );
    });
    test('should return "Stack trace not available"', () {
      final stackTrace = writeStacktrace(
        FlutterErrorDetails(exception: Exception('Test exception')),
      );
      expect(stackTrace, 'Stack trace not available');
    });
  });
}
