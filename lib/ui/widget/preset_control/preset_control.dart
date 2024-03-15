import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control/preset_control_vm.dart';
import 'package:provider/provider.dart';

class PresetControlWidget extends StatelessWidget {
  PresetControlWidget({
    required this.isLocal,
    super.key,
    this.category,
  }) {
    if (isLocal && category == null) {
      throw ArgumentError.notNull('category for local preset control');
    }
  }

  final bool isLocal;
  final ModCategory? category;

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final context) {
          if (isLocal) {
            return createLocalPresetControlViewModel(
              presetService: context.read(),
              category: category!,
            );
          } else {
            return createGlobalPresetControlViewModel(
              presetService: context.read(),
            );
          }
        },
        child: _PresetControlWidget(prefix: isLocal ? 'Local' : 'Global'),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isLocal', isLocal))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(DiagnosticsProperty<ModCategory?>('category', category));
  }
}

class _PresetControlWidget extends StatefulWidget {
  const _PresetControlWidget({required this.prefix});

  final String prefix;

  @override
  State<_PresetControlWidget> createState() => _PresetControlWidgetState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('prefix', prefix));
  }
}

class _PresetControlWidgetState extends State<_PresetControlWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAddIcon(),
          const SizedBox(width: 8),
          _buildComboBox(),
        ],
      );

  Widget _buildComboBox() => Selector<PresetControlViewModel, List<String>?>(
        selector: (final _, final vm) => vm.presets,
        builder: (final context, final value, final child) {
          final text = value != null
              ? '${widget.prefix} Preset...'
              : 'Grabbing ${widget.prefix} Presets...';
          return RepaintBoundary(
            child: ComboBox(
              items: value
                  ?.map((final e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              placeholder: Text(text),
              onChanged: (final value) => unawaited(
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (final dCtx) => _presetDialog(value!, dCtx),
                ),
              ),
            ),
          );
        },
      );

  ContentDialog _presetDialog(
    final String name,
    final BuildContext dialogContext,
  ) {
    final vm = context.read<PresetControlViewModel>();
    return ContentDialog(
      title: Text('Apply ${widget.prefix} Preset?'),
      content: Text('Preset name: $name'),
      actions: [
        FluentTheme(
          data: FluentTheme.of(context).copyWith(accentColor: Colors.red),
          child: FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              vm.removePreset(name);
            },
            child: const Text('Delete'),
          ),
        ),
        Button(
          onPressed: Navigator.of(dialogContext).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            vm.setPreset(name);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildAddIcon() => RepaintBoundary(
        child: IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: _onPresetAddPressed,
        ),
      );

  void _onPresetAddPressed() {
    unawaited(
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (final dCtx) => ContentDialog(
          title: Text('Add ${widget.prefix} Preset'),
          content: SizedBox(
            height: 40,
            child: TextBox(
              controller: _controller,
              placeholder: 'Preset Name',
            ),
          ),
          actions: [
            Button(
              onPressed: Navigator.of(dCtx).pop,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dCtx).pop();
                final text = _controller.text;
                _controller.clear();
                context.read<PresetControlViewModel>().addPreset(text);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
