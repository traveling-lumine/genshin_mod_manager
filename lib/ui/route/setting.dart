import 'dart:async';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/app_state.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/flow/app_version.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
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
        children: [
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
                  .read(appStateNotifierProvider.notifier)
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
                  .read(appStateNotifierProvider.notifier)
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
                  .read(appStateNotifierProvider.notifier)
                  .changeLauncherFile(file.path);
            },
          ),
          _SwitchItem(
            text: 'Run 3d migoto and launcher using one button',
            selector: (final value) => value.runTogether,
            onChanged:
                ref.read(appStateNotifierProvider.notifier).changeRunTogether,
          ),
          _SwitchItem(
            text: 'Move folder instead of copying for mod folder drag-and-drop',
            selector: (final value) => value.moveOnDrag,
            onChanged:
                ref.read(appStateNotifierProvider.notifier).changeMoveOnDrag,
          ),
          _SwitchItem(
            text: 'Show folder icon images',
            selector: (final value) => value.showFolderIcon,
            onChanged: ref
                .read(appStateNotifierProvider.notifier)
                .changeShowFolderIcon,
          ),
          _SwitchItem(
            text: 'Show enabled mods first',
            selector: (final value) => value.showEnabledModsFirst,
            onChanged: ref
                .read(appStateNotifierProvider.notifier)
                .changeShowEnabledModsFirst,
          ),
          _buildLicense(context),
          _buildVersion(ref),
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
  final String? Function(AppState vm) selector;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(title),
        subtitle: Consumer(
          builder: (final context, final ref, final child) {
            final value = ref.watch(appStateNotifierProvider.select(selector));
            return Text(value ?? 'Please select...');
          },
        ),
        trailing: RepaintBoundary(
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
        ObjectFlagProperty<String? Function(AppState vm)>.has(
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
    required this.selector,
    required this.onChanged,
  });

  final String text;
  final bool Function(AppState vm) selector;
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool value) onChanged;

  @override
  Widget build(final BuildContext context) => ListTile(
        title: Text(text),
        trailing: Consumer(
          builder: (final context, final ref, final child) {
            final value = ref.watch(appStateNotifierProvider.select(selector));
            return RepaintBoundary(
              child: ToggleSwitch(
                checked: value,
                onChanged: onChanged,
              ),
            );
          },
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(
        ObjectFlagProperty<bool Function(AppState vm)>.has(
          'selector',
          selector,
        ),
      )
      ..add(
        // ignore: avoid_positional_boolean_parameters
        ObjectFlagProperty<void Function(bool value)>.has(
          'onChanged',
          onChanged,
        ),
      );
  }
}
