import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../filesystem/di/ini_widget.dart';
import '../../filesystem/l0/entity/ini.dart';
import '../../filesystem/l1/impl/path_op_string.dart';

class IniWidget extends ConsumerStatefulWidget {
  const IniWidget({required this.iniFile, super.key});
  final IniFile iniFile;

  @override
  ConsumerState<IniWidget> createState() => _IniWidgetState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniFile>('iniFile', iniFile));
  }
}

class _EditorText extends HookConsumerWidget {
  const _EditorText({
    required this.lineNum,
    required this.keyBinding,
    required this.iniFile,
  });
  final int lineNum;
  final String keyBinding;

  final IniFile iniFile;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final textEditingController = useTextEditingController();
    useEffect(
      () {
        textEditingController.text = keyBinding;
        return null;
      },
      [keyBinding],
    );
    return Focus(
      onFocusChange: (final event) =>
          _onFocusChange(event, textEditingController),
      child: TextBox(
        controller: textEditingController,
        onSubmitted: (final value) => ref
            .read(iniLinesProvider(iniFile).notifier)
            .editIniFile(lineNum, value),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('value', keyBinding))
      ..add(IntProperty('lineNum', lineNum))
      ..add(DiagnosticsProperty<IniFile>('iniFile', iniFile));
  }

  void _onFocusChange(
    final bool focusGained,
    final TextEditingController textEditingController,
  ) {
    if (focusGained) {
      return;
    }
    // focus lost
    textEditingController.text = keyBinding;
  }
}

class _IniWidgetState extends ConsumerState<IniWidget> with WindowListener {
  @override
  Widget build(final BuildContext context) {
    final iniSections = ref.watch(iniLinesProvider(widget.iniFile));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIniHeader(widget.iniFile.path, ref),
        ...iniSections.when(
          data: (final data) => data
              .where(
                (final e) => e is! IniStatementVariable || e.numCycles > 1,
              )
              .map(
                (final e) => switch (e) {
                  IniStatementSection(:final name) => Text(name),
                  IniStatementVariable(:final numCycles) =>
                    Text('Cycles: $numCycles'),
                  IniStatementForward(
                    :final section,
                    :final lineNum,
                    :final value
                  ) =>
                    _buildForwardIniFieldEditor(
                      section.iniFile,
                      lineNum,
                      value,
                    ),
                  IniStatementBackward(
                    :final section,
                    :final lineNum,
                    :final value
                  ) =>
                    _buildBackwardIniFieldEditor(
                      section.iniFile,
                      lineNum,
                      value,
                    ),
                },
              ),
          error: (final error, final _) => [Text('Error: $error')],
          loading: () => [const Center(child: ProgressRing())],
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IniFile>('iniFile', widget.iniFile));
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    ref.invalidate(iniLinesProvider(widget.iniFile));
  }

  Widget _buildBackwardIniFieldEditor(
    final IniFile iniFile,
    final int lineNum,
    final String value,
  ) =>
      Row(
        children: [
          const Text('back:'),
          Expanded(
            child: _EditorText(
              iniFile: iniFile,
              lineNum: lineNum,
              keyBinding: value,
            ),
          ),
        ],
      );

  Widget _buildForwardIniFieldEditor(
    final IniFile iniFile,
    final int lineNum,
    final String value,
  ) =>
      Row(
        children: [
          const Text('key:'),
          Expanded(
            child: _EditorText(
              iniFile: iniFile,
              lineNum: lineNum,
              keyBinding: value,
            ),
          ),
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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
    final program = File(iniPath);
    final pwd = program.parent.path;
    final pName = program.path.pBasename;
    final obtainValue =
        ref.read(appConfigFacadeProvider).obtainValue(iniEditorArg);
    if (obtainValue == null || obtainValue.isEmpty) {
      await Process.run(
        'start',
        [pName],
        runInShell: true,
        workingDirectory: pwd,
      );
      return;
    }
    final iniEditorArgument =
        obtainValue.split(' ').map((final e) => e == '%0' ? null : e).toList();
    final List<String> arg;
    arg = iniEditorArgument.map((final e) => e ?? pName).toList();
    await Process.run(
      'start',
      ['/b', '', ...arg],
      runInShell: true,
      workingDirectory: pwd,
    );
  }
}
