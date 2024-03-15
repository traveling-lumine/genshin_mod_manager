import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:genshin_mod_manager/ui/route/category/mod_card/ini_widget_vm.dart';
import 'package:provider/provider.dart';

class IniWidget extends StatelessWidget {
  IniWidget({required this.iniFile}) : super(key: Key(iniFile.path));

  final IniFile iniFile;

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final context) => createIniWidgetViewModel(
          iniFile: iniFile,
          watcher: context.read(),
        ),
        child: _IniWidget(iniFile: iniFile),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniFile>('iniFile', iniFile));
  }
}

class _IniWidget extends StatefulWidget {
  const _IniWidget({required this.iniFile});

  final IniFile iniFile;

  @override
  State<_IniWidget> createState() => _IniWidgetState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniFile>('iniFile', iniFile));
  }
}

class _IniWidgetState extends State<_IniWidget> {
  List<String>? data;

  @override
  Widget build(final BuildContext context) {
    final future = context.watch<IniWidgetViewModel>().iniLines;
    return FutureBuilder(
      future: future,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIniHeader(widget.iniFile.path),
                  const ProgressRing(),
                  const Text('Loading ini file'),
                ],
              ),
            );
          } else {
            return _buildColumn(data!);
          }
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final list = snapshot.data!;
        data = list;
        return _buildColumn(list);
      },
    );
  }

  Column _buildColumn(final List<String> list) {
    final rowElements = <Widget>[];
    late String lastSection;
    var metSection = false;
    for (final line in data!) {
      if (line.startsWith('[')) {
        metSection = false;
      }
      final regExp = RegExp(r'\[Key.*?\]');
      final match = regExp.firstMatch(line)?.group(0);
      if (match != null) {
        rowElements.add(Text(match));
        lastSection = match;
        metSection = true;
      }
      final lineLower = line.toLowerCase();
      if (lineLower.startsWith('key')) {
        rowElements.add(
          _buildIniFieldEditor(
            'key:',
            IniSection(
              iniFile: widget.iniFile,
              line: line,
              section: lastSection,
            ),
          ),
        );
      } else if (lineLower.startsWith('back')) {
        rowElements.add(
          _buildIniFieldEditor(
            'back:',
            IniSection(
              iniFile: widget.iniFile,
              line: line,
              section: lastSection,
            ),
          ),
        );
      } else if (line.startsWith(r'$') && metSection) {
        final cycles = ','.allMatches(line.split(';').first).length + 1;
        rowElements.add(Text('Cycles: $cycles'));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIniHeader(widget.iniFile.path),
        ...rowElements,
      ],
    );
  }

  Widget _buildIniHeader(final String iniPath) {
    final basenameString = iniPath.pBasename;
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: basenameString,
            child: Text(
              basenameString,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        RepaintBoundary(
          child: Button(
            child: const Icon(FluentIcons.document_management),
            onPressed: () => runProgram(File(iniPath)),
          ),
        ),
      ],
    );
  }

  Widget _buildIniFieldEditor(
    final String data,
    final IniSection iniSection,
  ) =>
      Row(
        children: [
          Text(data),
          Expanded(
            child: _EditorText(
              iniSection: iniSection,
            ),
          ),
        ],
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('data', data));
  }
}

class _EditorText extends StatefulWidget {
  _EditorText({required this.iniSection}) : super(key: Key(iniSection.section));

  final IniSection iniSection;

  @override
  State<_EditorText> createState() => _EditorTextState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniSection>('iniSection', iniSection));
  }
}

class _EditorTextState extends State<_EditorText> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.iniSection.value);

  @override
  void didUpdateWidget(covariant final _EditorText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _textEditingController.text = widget.iniSection.value;
  }

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
    _textEditingController.text = widget.iniSection.value;
  }

  void _editIniKey(final String value) {
    context.read<IniWidgetViewModel>().editIniFile(widget.iniSection, value);
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<IniSection>('iniSection', widget.iniSection));
  }
}
