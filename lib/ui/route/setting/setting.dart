import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/route/setting/setting_vm.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/no_deref_file_opener.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

const _itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 16);

class SettingRoute extends StatelessWidget {
  const SettingRoute({super.key});

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final context) => createSettingViewModel(
          appStateService: context.read(),
        ),
        child: const _SettingRoute(),
      );
}

class _SettingRoute extends StatelessWidget {
  const _SettingRoute();

  @override
  Widget build(final BuildContext context) {
    final vm = context.read<SettingViewModel>();
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        _PathSelectItem(
          title: 'Select mod root folder',
          icon: FluentIcons.folder_open,
          selector: (final value) => value.modRoot,
          onPressed: () {
            final dir = DirectoryPicker().getDirectory();
            if (dir == null) return;
            vm.onModRootSelect(dir.path);
          },
        ),
        _PathSelectItem(
          title: 'Select 3D Migoto executable',
          icon: FluentIcons.document_management,
          selector: (final value) => value.modExecFile,
          onPressed: () {
            final file = OpenNoDereferenceFilePicker().getFile();
            if (file == null) return;
            vm.onModExecSelect(file.path);
          },
        ),
        _PathSelectItem(
          title: 'Select launcher',
          icon: FluentIcons.document_management,
          selector: (final value) => value.launcherFile,
          onPressed: () {
            final file = OpenNoDereferenceFilePicker().getFile();
            if (file == null) return;
            vm.onLauncherSelect(file.path);
          },
        ),
        _SwitchItem(
          text: 'Run 3d migoto and launcher using one button',
          selector: (final value) => value.runTogether,
          onChanged: vm.onRunTogetherChanged,
        ),
        _SwitchItem(
          text: 'Move folder instead of copying for mod folder drag-and-drop',
          selector: (final value) => value.moveOnDrag,
          onChanged: vm.onMoveOnDragChanged,
        ),
        _SwitchItem(
          text: 'Show folder icon images',
          selector: (final value) => value.showFolderIcon,
          onChanged: vm.onShowFolderIconChanged,
        ),
        _SwitchItem(
          text: 'Show enabled mods first',
          selector: (final value) => value.showEnabledModsFirst,
          onChanged: vm.onShowEnabledModsFirstChanged,
        ),
        Padding(
          padding: _itemPadding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Licenses',
                  style: FluentTheme.of(context).typography.bodyLarge,
                ),
              ),
              RepaintBoundary(
                child: Button(
                  onPressed: () => context.push(kLicenseRoute),
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: _itemPadding,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (final context, final snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...');
              }
              final packageInfo = snapshot.data!;
              return Text(
                'Version: ${packageInfo.version}',
                style: FluentTheme.of(context).typography.caption,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PathSelectItem extends StatelessWidget {
  const _PathSelectItem({
    required this.title,
    required this.icon,
    required this.selector,
    required this.onPressed,
  });

  final String title;
  final String? Function(SettingViewModel vm) selector;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: _itemPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FluentTheme.of(context).typography.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Selector<SettingViewModel, String?>(
                    selector: (final context, final vm) => selector(vm),
                    builder: (final context, final value, final child) => Text(
                      value ?? 'Loading...',
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ),
                ],
              ),
            ),
            RepaintBoundary(
              child: Button(
                onPressed: onPressed,
                child: Icon(icon),
              ),
            ),
          ],
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(DiagnosticsProperty<IconData>('icon', icon))
      ..add(
        ObjectFlagProperty<String? Function(SettingViewModel vm)>.has(
          'selector',
          selector,
        ),
      )
      ..add(
        ObjectFlagProperty<String? Function(SettingViewModel vm)>.has(
          'selector',
          selector,
        ),
      )
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
  final bool? Function(SettingViewModel vm) selector;
  final void Function(bool value) onChanged;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: _itemPadding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: FluentTheme.of(context).typography.bodyLarge,
              ),
            ),
            Selector<SettingViewModel, bool?>(
              selector: (final context, final vm) => selector(vm),
              builder: (final context, final value, final child) {
                if (value == null) {
                  return const Text('Loading...');
                }
                return RepaintBoundary(
                  child: ToggleSwitch(
                    checked: value,
                    onChanged: onChanged,
                  ),
                );
              },
            ),
          ],
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(
        ObjectFlagProperty<bool? Function(SettingViewModel vm)>.has(
          'selector',
          selector,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(bool value)>.has(
          'onChanged',
          onChanged,
        ),
      );
  }
}
