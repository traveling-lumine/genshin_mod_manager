import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l0/usecase/remove_global_preset.dart';
import '../../app_config/l0/usecase/remove_local_preset.dart';
import '../../app_config/l0/usecase/rename_global_preset.dart';
import '../../app_config/l0/usecase/rename_local_preset.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l0/usecase/add_global_preset.dart';
import '../../filesystem/l0/usecase/add_local_preset.dart';
import '../../filesystem/l0/usecase/set_global_preset.dart';
import '../../filesystem/l0/usecase/set_local_preset.dart';
import '../../filesystem/l1/di/filesystem.dart';
import '../../filesystem/l1/di/preset.dart';

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
          onPressed: () async {
            await _onPresetAdd(context, controller, ref);
          },
        ),
      ),
    );
  }

  Future<void> _onPresetAdd(
    final BuildContext context,
    final TextEditingController controller,
    final WidgetRef ref,
  ) =>
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
              onPressed: () async {
                Navigator.of(dCtx).pop();
                final text = controller.text;
                controller.clear();
                final appConfigFacade = ref.read(appConfigFacadeProvider);
                final appConfigRepo = ref.read(appConfigPersistentRepoProvider);
                final fs = ref.read(filesystemProvider);
                if (isLocal) {
                  final newState = await addLocalPresetUseCase(
                    facade: appConfigFacade,
                    fs: fs,
                    category: category!,
                    name: text,
                    appConfigRepo: appConfigRepo,
                  );
                  ref.read(appConfigCProvider.notifier).setData(newState);
                } else {
                  final newState = await addGlobalPresetUseCase(
                    appConfigFacade: appConfigFacade,
                    fs: fs,
                    appConfigRepo: appConfigRepo,
                    name: text,
                  );
                  if (newState != null) {
                    ref.read(appConfigCProvider.notifier).setData(newState);
                  }
                }
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
    final List<String> presetNames;
    if (isLocal) {
      presetNames = ref.watch(localPresetProvider(category!));
    } else {
      presetNames = ref.watch(globalPresetProvider);
    }
    return RepaintBoundary(
      child: ComboBox(
        items: presetNames
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
        categoryName: category!.name,
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
                onPressed: () async {
                  Navigator.of(dCtx).pop();
                  final currentGameConfig2 = ref
                      .read(appConfigFacadeProvider)
                      .obtainValue(games)
                      .currentGameConfig;
                  final read = ref.read(filesystemProvider);
                  if (isLocal) {
                    await setLocalPresetUseCase(
                      currentGameConfig2: currentGameConfig2,
                      category2: category!,
                      name: value,
                      fs: read,
                    );
                  } else {
                    await setGlobalPresetUseCase(
                      currentGameConfig2: currentGameConfig2,
                      name: value,
                      fs: read,
                    );
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      );

  Future<Object?> _showPresetRenameDialog(
    final BuildContext context,
    final String oldName,
    final WidgetRef ref,
  ) =>
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
                      final List<String> allPresetNames;
                      if (isLocal) {
                        allPresetNames =
                            ref.read(localPresetProvider(category!));
                      } else {
                        allPresetNames = ref.read(globalPresetProvider);
                      }
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
                        Navigator.of(dCtx).pop();
                        final newName = textController.text;
                        final presetData = ref
                            .read(appConfigFacadeProvider)
                            .obtainValue(games)
                            .currentGameConfig
                            .presetData;
                        final read = ref.read(appConfigFacadeProvider);
                        final read2 = ref.read(appConfigPersistentRepoProvider);
                        final newState = isLocal
                            ? renameLocalPresetUseCase(
                                presetData: presetData,
                                category2: category!.name,
                                oldName: oldName,
                                newName: newName,
                                read: read,
                                read2: read2,
                              )
                            : renameGlobalPresetUseCase(
                                presetData: presetData,
                                oldName: oldName,
                                newName: newName,
                                read: read,
                                read2: read2,
                              );
                        if (newState != null) {
                          ref
                              .read(appConfigCProvider.notifier)
                              .setData(newState);
                        }
                      },
                      child: const Text('Rename'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}
