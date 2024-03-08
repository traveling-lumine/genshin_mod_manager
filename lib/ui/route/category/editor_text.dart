import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class EditorText extends StatelessWidget {
  final String section;
  final String line;
  final File file;
  late final _lineValue = line.split('=').last.trim();
  late final textEditingController = TextEditingController(text: _lineValue);

  EditorText({
    super.key,
    required this.section,
    required this.line,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (event) {
        if (event) return;
        textEditingController.text = _lineValue;
      },
      child: TextBox(
        controller: textEditingController,
        onSubmitted: (value) => editIniKey(value),
      ),
    );
  }

  void editIniKey(String value) {
    bool metSection = false;
    final List<String> allLines = [];
    final lineHeader = line.split('=').first.trim();
    file.readAsLinesSync().forEach((element) {
      final regExp = RegExp(r'\[Key.*?\]').firstMatch(element);
      if (regExp != null && regExp.group(0) == section) {
        metSection = true;
      }
      if (metSection && element.toLowerCase() == line.toLowerCase()) {
        allLines.add('$lineHeader = ${value.trim()}');
      } else {
        allLines.add(element);
      }
    });
    file.writeAsStringSync(allLines.join('\n'));
  }
}
