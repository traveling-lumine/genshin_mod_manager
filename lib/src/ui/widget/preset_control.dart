import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/usecase/add_global_preset.dart';
import '../../app_config/l0/usecase/add_local_preset.dart';
import '../../app_config/l0/usecase/remove_global_preset.dart';
import '../../app_config/l0/usecase/remove_local_preset.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_config/l1/di/preset.dart';
import '../../filesystem/l0/entity/mod_category.dart';

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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('prefix', prefix))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(DiagnosticsProperty<bool>('isLocal', isLocal));
  }

  Widget _buildBox() =>
      _PresetComboBox(isLocal: isLocal, category: category, prefix: prefix);

  Widget _buildButton() {
    final controller = useTextEditingController();
    return RepaintBoundary(
      child: Consumer(
        builder: (final context, final ref, final child) => IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () async => _onPresetAdd(context, controller, ref),
        ),
      ),
    );
  }

  Future<void> _onPresetAdd(
    final BuildContext context,
    final TextEditingController controller,
    final WidgetRef ref,
  ) async =>
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
                final text = controller.text;
                controller.clear();
                final appConfigFacade = ref.read(appConfigFacadeProvider);
                final appConfigRepo = ref.read(appConfigPersistentRepoProvider);
                if (isLocal) {
                  final newState = addLocalPresetUseCase(
                    facade: appConfigFacade,
                    category: category!,
                    name: text,
                    appConfigRepo: appConfigRepo,
                  );
                  ref.read(appConfigCProvider.notifier).setData(newState);
                } else {
                  final newState = addGlobalPresetUseCase(
                    appConfigFacade: appConfigFacade,
                    appConfigRepo: appConfigRepo,
                    name: text,
                  );
                  if (newState != null) {
                    ref.read(appConfigCProvider.notifier).setData(newState);
                  }
                }
                Navigator.of(dCtx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
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
        onChanged: (final value) =>
            _showPresetActionDialog(context, value!, ref),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isLocal', isLocal))
      ..add(DiagnosticsProperty<ModCategory?>('category', category))
      ..add(StringProperty('prefix', prefix));
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

  List<String> _getPresets(final WidgetRef ref) {
    final List<String> value;
    if (isLocal) {
      value = ref.watch(localPresetNotifierProvider(category!));
    } else {
      value = ref.watch(globalPresetNotifierProvider);
    }
    return value;
  }

  void _onPresetDelete(
    final WidgetRef ref,
    final String value,
    final BuildContext dCtx,
  ) {
    final read = ref.read(appConfigFacadeProvider);
    final read2 = ref.read(appConfigPersistentRepoProvider);
    if (isLocal) {
      final newState = removeLocalPresetUseCase(
        read: read,
        category2: category!,
        name: value,
        read2: read2,
      );
      if (newState != null) {
        ref.read(appConfigCProvider.notifier).setData(newState);
      }
    } else {
      final newState = removeGlobalPresetUseCase(
        read: read,
        name: value,
        read2: read2,
      );
      ref.read(appConfigCProvider.notifier).setData(newState);
    }
    Navigator.of(dCtx).pop();
  }

  void _showPresetActionDialog(
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
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Preset name: $value'),
                Button(
                  onPressed: () {
                    Navigator.of(dCtx).pop();
                    _showPresetRenameDialog(context, value, ref);
                  },
                  child: const Text('Rename'),
                ),
              ],
            ),
            actions: [
              FluentTheme(
                data: FluentTheme.of(context).copyWith(accentColor: Colors.red),
                child: FilledButton(
                  onPressed: () => _onPresetDelete(ref, value, dCtx),
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

  void _showPresetRenameDialog(
    final BuildContext context,
    final String value,
    final WidgetRef ref,
  ) {
    unawaited(
      showDialog(
        context: context,
        builder: (final dCtx) => HookBuilder(
          builder: (final hCtx) {
            final textController = useTextEditingController();
            return Form(
              child: ContentDialog(
                title: Text('Rename $prefix Preset'),
                content: IntrinsicHeight(
                  child: TextFormBox(
                    placeholder: 'New Preset Name',
                    onChanged: (final value) => textController.text = value,
                    validator: (final value) {
                      if (value == null || value.isEmpty) {
                        return 'Preset name cannot be empty';
                      }
                      final allPresetNames = _getPresets(ref);
                      if (allPresetNames.contains(value)) {
                        return 'Preset name already exists';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  Button(
                    onPressed: Navigator.of(dCtx).pop,
                    child: const Text('Cancel'),
                  ),
                  Builder(
                    builder: (final bCtx) => FilledButton(
                      onPressed: () {
                        if (!Form.of(bCtx).validate()) {
                          return;
                        }
                        final text = textController.text;
                        _getNotifier(ref)
                            .renamePreset(oldName: value, newName: text);
                        Navigator.of(dCtx).pop();
                      },
                      child: const Text('Rename'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
