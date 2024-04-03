import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/preset.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PresetControlWidget extends HookWidget {
  PresetControlWidget({
    required this.isLocal,
    super.key,
    this.category,
  }) {
    if (isLocal && category == null) {
      throw ArgumentError.notNull('category for local preset control');
    }
  }

  /// Creates a [PresetControlWidget] for local presets.
  final bool isLocal;

  /// The category of the local preset control.
  final ModCategory? category;

  String get prefix => isLocal ? 'Local' : 'Global';

  @override
  Widget build(final BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(context),
          const SizedBox(width: 8),
          _buildBox(),
        ],
      );

  Widget _buildButton(final BuildContext context) {
    final controller = useTextEditingController();
    return RepaintBoundary(
      child: Consumer(
        builder: (final context, final ref, final child) => IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            _onPressed(context, controller, ref);
          },
        ),
      ),
    );
  }

  Widget _buildBox() => Consumer(
        builder: (final context, final ref, final child) {
          final List<String> value;
          if (isLocal) {
            value = ref.watch(localPresetNotifierProvider(category!));
          } else {
            value = ref.watch(globalPresetNotifierProvider);
          }
          return RepaintBoundary(
            child: ComboBox(
              items: value
                  .map((final e) => ComboBoxItem(value: e, child: Text(e)))
                  .toList(),
              placeholder: Text('$prefix Preset...'),
              onChanged: (final value) => unawaited(
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (final dCtx) => ContentDialog(
                    title: Text('Apply $prefix Preset?'),
                    content: Text('Preset name: ${value!}'),
                    actions: [
                      FluentTheme(
                        data: FluentTheme.of(context)
                            .copyWith(accentColor: Colors.red),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dCtx).pop();
                            if (isLocal) {
                              ref
                                  .read(
                                    localPresetNotifierProvider(category!)
                                        .notifier,
                                  )
                                  .removePreset(value);
                            } else {
                              ref
                                  .read(globalPresetNotifierProvider.notifier)
                                  .removePreset(value);
                            }
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
                          if (isLocal) {
                            ref
                                .read(
                                  localPresetNotifierProvider(category!)
                                      .notifier,
                                )
                                .setPreset(value);
                          } else {
                            ref
                                .read(globalPresetNotifierProvider.notifier)
                                .setPreset(value);
                          }
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('prefix', prefix));
  }

  void _onPressed(
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
          content: SizedBox(
            height: 40,
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
                if (isLocal) {
                  ref
                      .read(localPresetNotifierProvider(category!).notifier)
                      .addPreset(text);
                } else {
                  ref
                      .read(globalPresetNotifierProvider.notifier)
                      .addPreset(text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
