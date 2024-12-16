import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/error_handler/error_handler.dart';

void main() {
  group('elideLines', () {
    test('Elide no lines', () {
      const stackTrace = '''
#0      _onErrorHandler (package:genshin_mod_manager/src/error_handler.dart:22:3)
#1      FlutterError.onError (package:genshin_mod_manager/src/foundation/error.dart:209:5)
#2      _runApp (package:genshin_mod_manager/src/app.dart:19:3)
#3      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)''';
      final elided = elideLines(stackTrace);
      expect(
        elided,
        '''
#0      _onErrorHandler (package:genshin_mod_manager/src/error_handler.dart:22:3)
#1      FlutterError.onError (package:genshin_mod_manager/src/foundation/error.dart:209:5)
#2      _runApp (package:genshin_mod_manager/src/app.dart:19:3)
#3      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)''',
      );
    });
    test('Elide lines before', () {
      const stackTrace = '''
#0      _onErrorHandler (package:fluent_ui/src/error_handler.dart:22:3)
#1      FlutterError.onError (package:flutter/src/foundation/error.dart:209:5)
#2      _runApp (package:fluent_ui/src/app.dart:19:3)
#3      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)''';
      final elided = elideLines(stackTrace);
      expect(
        elided,
        '''
... (3 lines elided)
#3      _errorToString (package:genshin_mod_manager/src/error_handler.dart:42:3)''',
      );
    });
    test('Elide lines after', () {
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
    test('Elide lines before and after', () {
      const stackTrace = '''
#0      _onErrorHandler (package:genshin_mod_manager/src/error_handler.dart:22:3)
#1      FlutterError.onError (package:fluent_ui/src/foundation/error.dart:209:5)
#2      _runApp (package:genshin_mod_manager/src/app.dart:19:3)
#3      _errorToString (package:flutter/src/error_handler.dart:42:3)''';
      final elided = elideLines(stackTrace);
      expect(
        elided,
        '''
#0      _onErrorHandler (package:genshin_mod_manager/src/error_handler.dart:22:3)
... (1 lines elided)
#2      _runApp (package:genshin_mod_manager/src/app.dart:19:3)
... (1 lines elided)''',
      );
    });
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
  testWidgets(
    'Error widget text is selectable',
    (final tester) async {
      final details = FlutterErrorDetails(
        exception: Exception('Test exception'),
        stack: StackTrace.fromString('''asdf'''),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: errorWidgetBuilder(details),
        ),
      );

      final editableTextWidget =
          tester.widget<EditableText>(find.byType(EditableText));
      final editableTextState =
          tester.state<EditableTextState>(find.byType(EditableText));
      final controller = editableTextWidget.controller;

      // Double tap to select the second word.
      await tester.tap(find.byType(EditableText));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      expect(editableTextState.selectionOverlay!.handlesAreVisible, isTrue);
      expect(controller.selection, isNotNull);
    },
  );
}
