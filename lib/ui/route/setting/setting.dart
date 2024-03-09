import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/ui/route/setting/setting_vm.dart';
import 'package:genshin_mod_manager/ui/service/app_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

const _itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 16);

class SettingRoute extends StatelessWidget {
  const SettingRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingViewModel>(
      create: (context) {
        final appStateService = context.read<AppStateService>();
        return SettingViewModelImpl(appStateService: appStateService);
      },
      child: const _SettingRoute(),
    );
  }
}

class _SettingRoute extends StatelessWidget {
  const _SettingRoute();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SettingViewModel>();
    return ScaffoldPage.scrollable(
      header: const PageHeader(title: Text('Settings')),
      children: [
        _PathSelectItem(
          title: 'Select mod root folder',
          icon: FluentIcons.folder_open,
          selector: (value) => value.modRoot,
          onPressed: vm.onModRootSelect,
        ),
        _PathSelectItem(
          title: 'Select 3D Migoto executable',
          icon: FluentIcons.document_management,
          selector: (value) => value.modExecFile,
          onPressed: vm.onModExecSelect,
        ),
        _PathSelectItem(
          title: 'Select launcher',
          icon: FluentIcons.document_management,
          selector: (value) => value.launcherFile,
          onPressed: vm.onLauncherSelect,
        ),
        _SwitchItem(
          text: 'Run 3d migoto and launcher using one button',
          selector: (value) => value.runTogether,
          onChanged: vm.onRunTogetherChanged,
        ),
        _SwitchItem(
          text: 'Move folder instead of copying for mod folder drag-and-drop',
          selector: (value) => value.moveOnDrag,
          onChanged: vm.onMoveOnDragChanged,
        ),
        _SwitchItem(
          text: 'Show folder icon images',
          selector: (value) => value.showFolderIcon,
          onChanged: vm.onShowFolderIconChanged,
        ),
        _SwitchItem(
          text: 'Show enabled mods first',
          selector: (value) => value.showEnabledModsFirst,
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
                  onPressed: () => context.push('/license'),
                  child: const Text('View'),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: _itemPadding,
          child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...');
              }
              final packageInfo = snapshot.data as PackageInfo;
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
  final String title;
  final String Function(SettingViewModel vm) selector;
  final IconData icon;
  final VoidCallback onPressed;

  const _PathSelectItem({
    required this.title,
    required this.icon,
    required this.selector,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Selector<SettingViewModel, String>(
                  selector: (context, vm) => selector(vm),
                  builder: (context, value, child) {
                    return Text(
                      value,
                      style: FluentTheme.of(context).typography.caption,
                    );
                  },
                ),
              ],
            ),
          ),
          RepaintBoundary(
            child: Button(
              onPressed: onPressed,
              child: Icon(icon),
            ),
          )
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String text;
  final bool Function(SettingViewModel vm) selector;
  final void Function(bool value) onChanged;

  const _SwitchItem({
    required this.text,
    required this.selector,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _itemPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: FluentTheme.of(context).typography.bodyLarge,
            ),
          ),
          Selector<SettingViewModel, bool>(
            selector: (context, vm) => selector(vm),
            builder: (context, value, child) {
              return RepaintBoundary(
                child: ToggleSwitch(
                  checked: value,
                  onChanged: onChanged,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
