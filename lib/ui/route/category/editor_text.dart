import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class EditorText extends StatefulWidget {
  EditorText({
    required this.section,
    required this.line,
    required this.path,
    super.key,
  }) : _lineValue = line.split('=').last.trim();

  final String section;
  final String line;
  final String path;
  final String _lineValue;

  @override
  State<EditorText> createState() => _EditorTextState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('section', section))
      ..add(StringProperty('line', line))
      ..add(StringProperty('path', path));
  }
}

class _EditorTextState extends State<EditorText> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget._lineValue);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Focus(
        onFocusChange: _onFocusChange,
        child: TextBox(
          controller: _textEditingController,
          onSubmitted: _editIniKey,
        ),
      );

  void _onFocusChange(final event) {
    if (event) {
      return;
    }
    _textEditingController.text = widget._lineValue;
  }

  void _editIniKey(final String value) {
    var metSection = false;
    final allLines = <String>[];
    final lineHeader = widget.line.split('=').first.trim();
    final path = File(widget.path);
    path.readAsLinesSync().forEach((final element) {
      final regExp = RegExp(r'\[Key.*?\]').firstMatch(element);
      if (regExp != null && regExp.group(0) == widget.section) {
        metSection = true;
      }
      if (metSection && element.toLowerCase() == widget.line.toLowerCase()) {
        allLines.add('$lineHeader = ${value.trim()}');
      } else {
        allLines.add(element);
      }
    });
    path.writeAsStringSync(allLines.join('\n'));
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('section', widget.section))
      ..add(StringProperty('line', widget.line))
      ..add(StringProperty('path', widget.path))
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'textEditingController',
          _textEditingController,
        ),
      );
  }
}
