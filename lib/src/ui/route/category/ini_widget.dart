import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../backend/fs_interface/data/helper/path_op_string.dart';
import '../../../backend/structure/entity/ini.dart';
import '../../di/fs_interface.dart';
import '../../di/ini_widget.dart';

class IniWidget extends ConsumerWidget {
  const IniWidget({required this.iniFile, super.key});
  final IniFile iniFile;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final lines = ref.watch(iniLinesProvider(iniFile));
    return _buildColumn(lines, ref);
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniFile>('iniFile', iniFile));
  }

  Widget _buildColumn(final List<String> data, final WidgetRef ref) {
    final rowElements = <Widget>[];
    late String lastSection;
    var metSection = false;
    for (final line in data) {
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
              iniFile: iniFile,
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
              iniFile: iniFile,
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
        _buildIniHeader(iniFile.path, ref),
        ...rowElements,
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
          Expanded(child: _EditorText(iniSection: iniSection)),
        ],
      );

  Widget _buildIniHeader(final String iniPath, final WidgetRef ref) {
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
          child: IconButton(
            icon: const Icon(FluentIcons.document_management),
            onPressed: () async => _onIniOpen(ref, iniPath),
          ),
        ),
      ],
    );
  }

  Future<void> _onIniOpen(final WidgetRef ref, final String iniPath) async {
    final fsInterface = ref.read(fsInterfaceProvider);
    await fsInterface.runIniEdit(File(iniPath));
  }
}

class _EditorText extends HookConsumerWidget {
  const _EditorText({required this.iniSection});
  final IniSection iniSection;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final textEditingController = useTextEditingController();
    useEffect(
      () {
        textEditingController.text = iniSection.value;
        return null;
      },
      [iniSection.value],
    );
    return Focus(
      onFocusChange: (final event) =>
          _onFocusChange(event, textEditingController),
      child: TextBox(
        controller: textEditingController,
        onSubmitted: (final value) {
          ref
              .read(iniLinesProvider(iniSection.iniFile).notifier)
              .editIniFile(iniSection, value);
        },
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniSection>('iniSection', iniSection));
  }

  void _onFocusChange(
    final bool event,
    final TextEditingController textEditingController,
  ) {
    if (event) {
      return;
    }
    textEditingController.text = iniSection.value;
  }
}
