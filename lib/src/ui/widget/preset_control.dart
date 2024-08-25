import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/structure/entity/mod_category.dart';
import '../../di/preset.dart';

/// A widget that provides a control for presets.
class PresetControlWidget extends HookWidget {
  /// Creates a [PresetControlWidget].
  PresetControlWidget({
    required this.isLocal,
    super.key,
    this.category,
  }) {
    if (isLocal && category == null) {
      throw ArgumentError.notNull('category for local preset control');
    }
  }

  /// Whether the preset control is local.
  final bool isLocal;

  /// The category of the local preset control.
  final ModCategory? category;

  /// The prefix of the preset control.
  String get prefix => isLocal ? 'Local' : 'Global';

  @override
  Widget build(final BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(),
          const SizedBox(width: 8),
          _buildBox(),
        ],
      );

  Widget _buildButton() {
    final controller = useTextEditingController();
    return RepaintBoundary(
      child: Consumer(
        builder: (final context, final ref, final child) => IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            _onPresetAdd(context, controller, ref);
          },
        ),
      ),
    );
  }

  Widget _buildBox() =>
      _PresetComboBox(isLocal: isLocal, category: category, prefix: prefix);

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('prefix', prefix))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(DiagnosticsProperty<bool>('isLocal', isLocal));
  }

  void _onPresetAdd(
    final BuildContext context,
    final TextEditingController controller,
    final WidgetRef ref,
  ) {
    unawaited(
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (final dCtx) => ContentDialog(
          title: Text('Add $prefix Preset'),
          content: IntrinsicHeight(
            child: TextBox(
              controller: controller,
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
                final text = controller.text;
                controller.clear();
                _getNotifier(ref).addPreset(text);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  PresetNotifier _getNotifier(final WidgetRef ref) {
    final PresetNotifier notifier;
    if (isLocal) {
      notifier = ref.read(localPresetNotifierProvider(category!).notifier);
    } else {
      notifier = ref.read(globalPresetNotifierProvider.notifier);
    }
    return notifier;
  }
}

class _PresetComboBox extends ConsumerWidget {
  const _PresetComboBox({
    required this.isLocal,
    required this.category,
    required this.prefix,
  });

  final bool isLocal;
  final ModCategory? category;
  final String prefix;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = _getPresets(ref);
    return RepaintBoundary(
      child: ComboBox(
        items: value
            .map((final e) => ComboBoxItem(value: e, child: Text(e)))
            .toList(),
        placeholder: Text('$prefix Preset...'),
        onChanged: (final value) => _onBoxChanged(context, value!, ref),
      ),
    );
  }

  void _onBoxChanged(
    final BuildContext context,
    final String value,
    final WidgetRef ref,
  ) =>
      unawaited(
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (final dCtx) => ContentDialog(
            title: Text('Apply $prefix Preset?'),
            content: Text('Preset name: $value'),
            actions: [
              FluentTheme(
                data: FluentTheme.of(context).copyWith(accentColor: Colors.red),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dCtx).pop();
                    _getNotifier(ref).removePreset(value);
                  },
                  child: const Text('Delete'),
                ),
              ),
              Button(
                onPressed: Navigator.of(dCtx).pop,
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dCtx).pop();
                  _getNotifier(ref).setPreset(value);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      );

  List<String> _getPresets(final WidgetRef ref) {
    final List<String> value;
    if (isLocal) {
      value = ref.watch(localPresetNotifierProvider(category!));
    } else {
      value = ref.watch(globalPresetNotifierProvider);
    }
    return value;
  }

  PresetNotifier _getNotifier(final WidgetRef ref) {
    final PresetNotifier notifier;
    if (isLocal) {
      notifier = ref.read(
        localPresetNotifierProvider(category!).notifier,
      );
    } else {
      notifier = ref.read(globalPresetNotifierProvider.notifier);
    }
    return notifier;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isLocal', isLocal))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(StringProperty('prefix', prefix));
  }
}
