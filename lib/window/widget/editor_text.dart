import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class EditorText extends StatelessWidget {
  final focusNode = FocusNode();
  final String section;
  final String line;
  final File file;

  EditorText({
    super.key,
    required this.section,
    required this.line,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final String text = line.split('=').last.trim();
    final textEditingController = TextEditingController(text: text);
    return Focus(
      focusNode: focusNode,
      onFocusChange: (event) {
        if (event) return;
        textEditingController.text = text;
        focusNode.unfocus();
      },
      child: TextBox(
        controller: textEditingController,
        onSubmitted: (value) {
          bool metSection = false;
          List<String> allLines = [];
          final lineHeader = line.split('=').first.trim();
          file.readAsLinesSync().forEach((element) {
            final regExp = RegExp(r'\[Key.*?\]').firstMatch(element);
            if (regExp != null && regExp.group(0) == section) {
              metSection = true;
            }
            if (metSection && element.toLowerCase() == line.toLowerCase()) {
              final first = '$lineHeader ';
              allLines.add('$first= ${value.trim()}');
            } else {
              allLines.add(element);
            }
          });
          file.writeAsStringSync(allLines.join('\n'));
        },
      ),
    );
  }
}
