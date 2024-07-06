import 'dart:async';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show AlertDialog;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/domain/entity/game_config.dart';
import 'package:genshin_mod_manager/domain/usecase/app_state/card_color.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/flow/app_version.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/widget/game_selector.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/no_deref_file_opener.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A route that shows the settings.
class SettingRoute extends StatelessWidget {
  /// Creates a [SettingRoute].
  const SettingRoute({super.key});

  @override
  Widget build(final BuildContext context) => const _SettingRoute();
}

class _SettingRoute extends ConsumerWidget {
  const _SettingRoute();

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      ScaffoldPage.scrollable(
        header: const PageHeader(title: Text('Settings')),
        bottomBar: Column(
          children: [
            _buildLicense(context),
            _buildVersion(ref),
          ],
        ),
        children: [
          const _SectionHeader(title: 'Paths'),
          _PathSelectItem(
            title: 'Select mod root folder',
            icon: FluentIcons.folder_open,
            selector: (final value) => value.modRoot,
            onPressed: () {
              final dir = DirectoryPicker().getDirectory();
              if (dir == null) {
                return;
              }
              ref
                  .read(gameConfigNotifierProvider.notifier)
                  .changeModRoot(dir.path);
            },
          ),
          _PathSelectItem(
            title: 'Select 3D Migoto executable',
            icon: FluentIcons.document_management,
            selector: (final value) => value.modExecFile,
            onPressed: () {
              final file = OpenNoDereferenceFilePicker().getFile();
              if (file == null) {
                return;
              }
              ref
                  .read(gameConfigNotifierProvider.notifier)
                  .changeModExecFile(file.path);
            },
          ),
          _PathSelectItem(
            title: 'Select launcher',
            icon: FluentIcons.document_management,
            selector: (final value) => value.launcherFile,
            onPressed: () {
              final file = OpenNoDereferenceFilePicker().getFile();
              if (file == null) {
                return;
              }
              ref
                  .read(gameConfigNotifierProvider.notifier)
                  .changeLauncherFile(file.path);
            },
          ),
          const _SectionHeader(title: 'Options'),
          _SwitchItem(
            text: 'Run 3d migoto and launcher using one button',
            provider: runTogetherProvider,
          ),
          _SwitchItem(
            text: 'Move folder instead of copying for mod folder drag-and-drop',
            provider: moveOnDragProvider,
          ),
          _SwitchItem(
            text: 'Show folder icon images',
            provider: folderIconProvider,
          ),
          _SwitchItem(
            text: 'Show enabled mods first',
            provider: enabledFirstProvider,
          ),
          _SwitchItem(
            text: 'Dark mode',
            provider: darkModeProvider,
          ),
          const _ComboItem(
            text: 'Target Game',
          ),
          const _SectionHeader(title: 'Themes'),
          const _SectionSubheader(
            title: 'Card colors (hover on the icons to see details)',
          ),
          const _ColorChanger(isBright: true, isEnabled: true),
          const _ColorChanger(isBright: true, isEnabled: false),
          const _ColorChanger(isBright: false, isEnabled: true),
          const _ColorChanger(isBright: false, isEnabled: false),
        ],
      );

  Widget _buildLicense(final BuildContext context) => ListTile(
        title: const Text('Licenses'),
        trailing: Button(
          onPressed: () => unawaited(context.push(kLicenseRoute)),
          child: const Text('View'),
        ),
      );

  Widget _buildVersion(final WidgetRef ref) => ListTile(
        title: Consumer(
          builder: (final context, final ref, final child) {
            final curVersion = ref.watch(versionStringProvider).when(
                  data: (final version) => version,
                  error: (final error, final stackTrace) => '(error)',
                  loading: () => 'Loading...',
                );
            final isOutdated = ref.watch(isOutdatedProvider).maybeWhen(
                  data: (final value) => value ? '(new version available)' : '',
                  orElse: () => '',
                );
            return Text(
              'Version: $curVersion $isOutdated',
              style: FluentTheme.of(context).typography.caption,
            );
          },
        ),
        trailing: RepaintBoundary(
          child: Button(
            child: const Icon(FluentIcons.refresh),
            onPressed: () {
              ref.invalidate(remoteVersionProvider);
            },
          ),
        ),
      );
}

class _PathSelectItem extends StatelessWidget {
  const _PathSelectItem({
    required this.title,
    required this.icon,
    required this.selector,
    required this.onPressed,
  });

  final String title;
  final String? Function(GameConfig vm) selector;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Consumer(
          builder: (final context, final ref, final child) {
            final value =
                ref.watch(gameConfigNotifierProvider.select(selector));
            return Text(value ?? 'Please select...');
          },
        ),
        leading: RepaintBoundary(
          child: Button(
            onPressed: onPressed,
            child: Icon(icon),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(
        ObjectFlagProperty<String? Function(GameConfig vm)>.has(
          'selector',
          selector,
        ),
      )
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.text,
    required this.provider,
  });

  final String text;
  final AutoDisposeNotifierProvider<ValueSettable, bool> provider;

  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(text),
        leading: Consumer(
          builder: (final context, final ref, final child) => RepaintBoundary(
            child: ToggleSwitch(
              checked: ref.watch(provider),
              onChanged: (final value) {
                ref.read(provider.notifier).setValue(value);
              },
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(
        DiagnosticsProperty<ProviderListenable<bool>>('provider', provider),
      );
  }
}

class _ComboItem extends StatelessWidget {
  const _ComboItem({
    required this.text,
  });

  final String text;

  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(text),
        leading: const GameSelector(),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Text(
          title,
          style: FluentTheme.of(context).typography.subtitle,
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _SectionSubheader extends StatelessWidget {
  const _SectionSubheader({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: Text(
          title,
          style: FluentTheme.of(context).typography.bodyLarge,
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _ColorChanger extends ConsumerWidget {
  const _ColorChanger({
    required this.isBright,
    required this.isEnabled,
  });

  final bool isBright;
  final bool isEnabled;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final description = "Changes the"
        " ${isBright ? 'bright' : 'dark'} mode themed,"
        " ${isEnabled ? 'enabled' : 'disabled'} card's color.";

    Widget brightModeIcon = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(isBright ? FluentIcons.sunny : FluentIcons.clear_night),
    );
    if (isBright != ref.watch(darkModeProvider)) {
      // add a green border to indicate that the color is visible
      brightModeIcon = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: brightModeIcon,
      );
    }
    return ListTile(
      title: FluentTheme(
        data: FluentTheme.of(context).copyWith(
          tooltipTheme: TooltipTheme.of(context).merge(
            const TooltipThemeData(
              waitDuration: Duration(milliseconds: 200),
              showDuration: Duration(days: 1),
            ),
          ),
        ),
        child: Tooltip(
          message: description,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              brightModeIcon,
              const SizedBox(width: 8),
              Icon(isEnabled ? FluentIcons.accept : FluentIcons.clear),
            ],
          ),
        ),
      ),
      leading: Consumer(
        builder: (final context, final ref, final child) => RepaintBoundary(
          child: GestureDetector(
            onTap: () {
              unawaited(
                showGeneralDialog(
                  context: context,
                  pageBuilder: (final context, final _, final __) =>
                      _ColorPickerDialog(
                    isBright: isBright,
                    isEnabled: isEnabled,
                  ),
                ),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ref.watch(
                  cardColorProvider(
                    isBright: isBright,
                    isEnabled: isEnabled,
                  ),
                ),
                border: Border.all(
                  color: FluentTheme.of(context).inactiveColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('isBright', value: isBright, ifTrue: 'bright'))
      ..add(FlagProperty('isEnabled', value: isEnabled, ifTrue: 'enabled'));
  }
}

class _ColorPickerDialog extends HookConsumerWidget {
  const _ColorPickerDialog({
    required this.isBright,
    required this.isEnabled,
  });

  final bool isBright;
  final bool isEnabled;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final currentColor = useState(
      ref.watch(
        cardColorProvider(isBright: isBright, isEnabled: isEnabled),
      ),
    );
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor.value,
          onColorChanged: (final value) {
            currentColor.value = value;
          },
        ),
      ),
      actions: [
        Button(
          onPressed: () {
            final defaultColor = getDefaultValueUseCase(
              isBright: isBright,
              isEnabled: isEnabled,
            );
            ref
                .read(
                  cardColorProvider(isBright: isBright, isEnabled: isEnabled)
                      .notifier,
                )
                .setColor(defaultColor);
            Navigator.of(context).pop();
          },
          child: const Text('Restore default'),
        ),
        Button(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: () {
            ref
                .read(
                  cardColorProvider(isBright: isBright, isEnabled: isEnabled)
                      .notifier,
                )
                .setColor(currentColor.value);
            Navigator.of(context).pop();
          },
          child: const Text('Set'),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isBright', isBright))
      ..add(DiagnosticsProperty<bool>('isEnabled', isEnabled));
  }
}
