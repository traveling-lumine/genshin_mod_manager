import 'dart:async';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../app_config/l0/entity/column_strategy.dart';
import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l0/entity/game_config.dart';
import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l0/usecase/change_game_separate_run_override.dart';
import '../../app_config/l0/usecase/change_mod_exec.dart';
import '../../app_config/l0/usecase/change_mod_launcher.dart';
import '../../app_config/l0/usecase/change_mod_root.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_version/di/current_version.dart';
import '../../app_version/di/is_outdated.dart';
import '../../app_version/di/remote_version.dart';
import '../constants.dart';
import '../widget/game_selector.dart';
import '../widget/ini_editor_arg_setting.dart';
import '../widget/setting_element.dart';
import '../widget/switch_setting.dart';

class SettingRoute extends ConsumerWidget {
  const SettingRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      ScaffoldPage.withPadding(
        header: const PageHeader(title: Text('Settings')),
        bottomBar: Column(
          children: [
            _buildLicense(context),
            _buildVersion(ref),
          ],
        ),
        content: _buildContent(ref),
      );

  Widget _buildContent(final WidgetRef ref) => DynMouseScroll(
        scrollSpeed: 1,
        builder: (final context, final scrollController, final scrollPhysics) =>
            ListView(
          controller: scrollController,
          physics: scrollPhysics,
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
                final newConfig = changeModRootUseCase(
                  appConfigFacade: ref.read(appConfigFacadeProvider),
                  appConfigPersistentRepo:
                      ref.read(appConfigPersistentRepoProvider),
                  value: dir.path,
                );
                ref.read(appConfigCProvider.notifier).setData(newConfig);
              },
            ),
            _PathSelectItem(
              title: 'Select 3D Migoto executable',
              icon: FluentIcons.document_management,
              selector: (final value) => value.modExecFile,
              onPressed: () {
                final file =
                    (OpenFilePicker()..dereferenceLinks = false).getFile();
                if (file == null) {
                  return;
                }
                final newConfig = changeModExecUseCase(
                  appConfigFacade: ref.read(appConfigFacadeProvider),
                  appConfigPersistentRepo:
                      ref.read(appConfigPersistentRepoProvider),
                  value: file.path,
                );
                ref.read(appConfigCProvider.notifier).setData(newConfig);
              },
            ),
            _PathSelectItem(
              title: 'Select launcher',
              icon: FluentIcons.document_management,
              selector: (final value) => value.launcherFile,
              onPressed: () {
                final file =
                    (OpenFilePicker()..dereferenceLinks = false).getFile();
                if (file == null) {
                  return;
                }
                final newConfig = changeModLauncherUseCase(
                  appConfigFacade: ref.read(appConfigFacadeProvider),
                  appConfigPersistentRepo:
                      ref.read(appConfigPersistentRepoProvider),
                  value: file.path,
                );
                ref.read(appConfigCProvider.notifier).setData(newConfig);
              },
            ),
            const _SectionHeader(title: 'Options'),
            SwitchSetting(
              text: 'Run 3d migoto and launcher using one button',
              entry: runTogether,
              content: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Checkbox(
                      checked: ref.watch(
                        appConfigFacadeProvider.select(
                          (final value) => value
                              .obtainValue(games)
                              .currentGameConfig
                              .separateRunOverride,
                        ),
                      ),
                      onChanged: (final value) {
                        final res = switch (value) {
                          true => null,
                          false => false,
                          null => true,
                        };
                        final newConfig = changeGameSeparateRunOverrideUseCase(
                          appConfigFacade: ref.read(appConfigFacadeProvider),
                          appConfigPersistentRepo: ref.read(
                            appConfigPersistentRepoProvider,
                          ),
                          value: res,
                        );
                        ref
                            .read(appConfigCProvider.notifier)
                            .setData(newConfig);
                      },
                    ),
                  ),
                  const Text('Per-game Override'),
                ],
              ),
            ),
            SwitchSetting(
              text:
                  'Move folder instead of copying for mod folder drag-and-drop',
              entry: moveOnDrag,
            ),
            SwitchSetting(
              text: 'Show folder icon images',
              entry: showFolderIcon,
            ),
            SwitchSetting(
              text: 'Show enabled mods first',
              entry: showEnabledModsFirst,
            ),
            SwitchSetting(text: 'Dark mode', entry: darkMode),
            const SettingElement(text: 'Target Game', trailing: GameSelector()),
            const _SectionHeader(title: 'Themes'),
            const SettingElement(
              text: 'Card colors (hover on the icons to see details)',
              initiallyExpanded: true,
              content: Column(
                children: [
                  _ColorChanger(isBright: true, isEnabled: true),
                  _ColorChanger(isBright: true, isEnabled: false),
                  _ColorChanger(isBright: false, isEnabled: true),
                  _ColorChanger(isBright: false, isEnabled: false),
                ],
              ),
            ),
            Consumer(
              builder: (final context, final ref, final child) {
                final watch = ref.watch(
                  appConfigFacadeProvider.select(
                    (final value) => value.obtainValue(columnStrategy),
                  ),
                );
                return SettingElement(
                  initiallyExpanded: true,
                  text: 'Column Display Strategy',
                  trailing: ComboBox(
                    value: watch.current,
                    items: const [
                      ComboBoxItem(
                        value: ColumnStrategyEntryEnum.fixedCount(),
                        child: Text('Fixed Count'),
                      ),
                      ComboBoxItem(
                        value: ColumnStrategyEntryEnum.maxExtent(),
                        child: Text('Max Extent'),
                      ),
                      ComboBoxItem(
                        value: ColumnStrategyEntryEnum.minExtent(),
                        child: Text('Min Extent'),
                      ),
                    ],
                    onChanged: (final value) {
                      if (value == null) {
                        return;
                      }
                      final newColumnStrategy = watch.copyWith(current: value);
                      final newConfig =
                          changeAppConfigUseCase<ColumnStrategySettingMediator>(
                        appConfigFacade: ref.read(appConfigFacadeProvider),
                        appConfigPersistentRepo:
                            ref.read(appConfigPersistentRepoProvider),
                        entry: columnStrategy,
                        value: newColumnStrategy,
                      );
                      ref.read(appConfigCProvider.notifier).setData(newConfig);
                    },
                  ),
                  content: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          watch.current.when(
                            fixedCount: () => 'Fixed number of columns',
                            maxExtent: () => 'Column max width limit',
                            minExtent: () => 'Column min width limit',
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: NumberBox<int>(
                            value: watch.current.when(
                              fixedCount: () => watch.fixedCount,
                              maxExtent: () => watch.maxExtent,
                              minExtent: () => watch.minExtent,
                            ),
                            onChanged: (final value) {
                              if (value == null) {
                                return;
                              }
                              final newColumnStrategy = watch.current.when(
                                fixedCount: () => watch.copyWith(
                                  fixedCount: value,
                                ),
                                maxExtent: () => watch.copyWith(
                                  maxExtent: value,
                                ),
                                minExtent: () => watch.copyWith(
                                  minExtent: value,
                                ),
                              );

                              final newConfig = changeAppConfigUseCase<
                                  ColumnStrategySettingMediator>(
                                appConfigFacade:
                                    ref.read(appConfigFacadeProvider),
                                appConfigPersistentRepo: ref.read(
                                  appConfigPersistentRepoProvider,
                                ),
                                entry: columnStrategy,
                                value: newColumnStrategy,
                              );
                              ref
                                  .read(appConfigCProvider.notifier)
                                  .setData(newConfig);
                            },
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const _SectionHeader(title: 'Misc'),
            const IniEditorArgSetting(title: 'Ini file editor arguments'),
            SwitchSetting(
              text: 'Use Paimon for folders without icons',
              entry: showPaimonAsEmptyIconFolderIcon,
            ),
            const SizedBox(height: 200),
          ],
        ),
      );

  Widget _buildLicense(final BuildContext context) => ListTile(
        title: const Text('Licenses'),
        trailing: Button(
          onPressed: () => context.goNamed(RouteNames.license.name),
          child: const Text('View'),
        ),
      );

  Widget _buildVersion(final WidgetRef ref) => ListTile(
        title: Consumer(
          builder: (final context, final ref, final child) {
            final curVersion = ref.watch(versionStringProvider).when(
                  data: (final version) => version.formatted,
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

class _ColorChanger extends ConsumerWidget {
  const _ColorChanger({
    required this.isBright,
    required this.isEnabled,
  });
  final bool isBright;
  final bool isEnabled;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final description = 'Changes the'
        " ${isBright ? 'bright' : 'dark'} mode themed,"
        " ${isEnabled ? 'enabled' : 'disabled'} card's color.";

    Widget brightModeIcon = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(isBright ? FluentIcons.sunny : FluentIcons.clear_night),
    );
    if (isBright !=
        ref.watch(
          appConfigFacadeProvider
              .select((final value) => value.obtainValue(darkMode)),
        )) {
      // add a green border to indicate that the color is visible
      brightModeIcon = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: brightModeIcon,
      );
    }
    final entry = switch ((isBright, isEnabled)) {
      (false, false) => cardColorDarkDisabled,
      (false, true) => cardColorDarkEnabled,
      (true, false) => cardColorBrightDisabled,
      (true, true) => cardColorBrightEnabled,
    };
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
                  appConfigFacadeProvider.select(
                    (final value) => value.obtainValue(entry),
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
    final entry = switch ((isBright, isEnabled)) {
      (false, false) => cardColorDarkDisabled,
      (false, true) => cardColorDarkEnabled,
      (true, false) => cardColorBrightDisabled,
      (true, true) => cardColorBrightEnabled,
    };
    final currentColor = useState(
      ref.watch(
        appConfigFacadeProvider
            .select((final value) => value.obtainValue(entry)),
      ),
    );
    return ContentDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          color: currentColor.value,
          onChanged: (final value) => currentColor.value = value,
        ),
      ),
      actions: [
        Button(
          onPressed: () {
            final defaultColor = entry.defaultValue;
            final newState = changeAppConfigUseCase(
              appConfigFacade: ref.read(appConfigFacadeProvider),
              appConfigPersistentRepo:
                  ref.read(appConfigPersistentRepoProvider),
              entry: entry,
              value: defaultColor,
            );
            ref.read(appConfigCProvider.notifier).setData(newState);
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
            final newState = changeAppConfigUseCase(
              appConfigFacade: ref.read(appConfigFacadeProvider),
              appConfigPersistentRepo:
                  ref.read(appConfigPersistentRepoProvider),
              entry: entry,
              value: currentColor.value,
            );
            ref.read(appConfigCProvider.notifier).setData(newState);
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
  Widget build(final BuildContext context) => SettingElement(
        text: title,
        trailing: RepaintBoundary(
          child: Button(onPressed: onPressed, child: Icon(icon)),
        ),
        subTitle: Consumer(
          builder: (final context, final ref, final child) {
            final value = ref.watch(
              appConfigFacadeProvider.select(
                (final value) =>
                    selector(value.obtainValue(games).currentGameConfig),
              ),
            );
            return Text(value ?? 'Please select...');
          },
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, left: 8, right: 16, bottom: 8),
        child: Text(title, style: FluentTheme.of(context).typography.subtitle),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}
