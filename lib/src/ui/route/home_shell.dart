import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart'
    hide AutoSuggestBox, AutoSuggestBoxItem;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_config/l1/entity/entries.dart';
import '../../app_version/di/is_outdated.dart';
import '../../filesystem/l1/di/categories.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import '../../l10n/app_localizations.dart';
import '../constants.dart';
import '../util/display_infobar.dart';
import '../widget/appbar.dart';
import '../widget/category_pane_item.dart';
import '../widget/download_queue.dart';
import '../widget/protocol_handler.dart';
import '../widget/protocol_url_forward_widget.dart';
import '../widget/run_pane.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';
import '../widget/update_popup.dart';
import '../widget/window_listener.dart';

class HomeShell extends StatefulHookConsumerWidget {
  const HomeShell({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState<T extends StatefulWidget> extends ConsumerState<HomeShell>
    with WindowListener {
  static const _navigationPaneOpenWidth = 270.0;

  @override
  Widget build(final BuildContext context) {
    final game = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(games).current!),
    );
    final updateMarker =
        (ref.watch(isOutdatedProvider).valueOrNull ?? false) ? 'update' : '';
    return ProtocolUrlForwardWidget(
      child: WindowListenerWidget(
        child: UpdatePopup(
          child: DownloadQueue(
            child: ProtocolHandlerWidget(
              runBothCallback: _runBoth,
              runLauncherCallback: _runLauncher,
              runMigotoCallback: _runMigoto,
              child: NavigationView(
                appBar: getAppbar(
                  AppLocalizations.of(context)!.modManager(game, updateMarker),
                  presetControl: true,
                ),
                pane: _buildPane(),
                paneBodyBuilder: (final item, final body) => widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);

    final read = ref.read(appConfigFacadeProvider).obtainValue(windowSize);
    if (read != null) {
      unawaited(WindowManager.instance.setSize(read));
    }
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    unawaited(_saveNewWindowSize());
  }

  Widget _buildAutoSuggestBox(
    final List<FolderPaneItem> items,
    final ScrollController controller,
  ) =>
      AutoSuggestBox(
        items: items.indexed
            .map(
              (final e) => AutoSuggestBoxItem(
                value: e.$2.category,
                label: e.$2.category.name,
                onSelected: () {
                  e.$2.onTap?.call();
                  unawaited(
                    controller.animateTo(
                      e.$1 * 84.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    ),
                  );
                },
              ),
            )
            .toList(),
        trailingIcon: const Icon(FluentIcons.search),
        onSubmissionFailed: (final text) {
          if (text.isEmpty) {
            return;
          }
          final item = items.indexed.firstWhereOrNull((final e) {
            final name = e.$2.category.name.toLowerCase();
            return name.startsWith(text.toLowerCase());
          });
          if (item == null) {
            return;
          }
          item.$2.onTap?.call();
          unawaited(
            controller.animateTo(
              item.$1 * 84.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
          );
        },
      );

  NavigationPane _buildPane() {
    final controller = useScrollController();
    final valueOrNull2 = ref.watch(categoriesProvider).valueOrNull;
    final items = valueOrNull2 == null
        ? <FolderPaneItem>[]
        : valueOrNull2
            .map(
              (final e) => FolderPaneItem(
                category: e,
                key: Key('/${RouteNames.category.name}/${e.name}'),
                onTap: () => context.goNamed(
                  RouteNames.category.name,
                  pathParameters: {RouteParams.category.name: e.name},
                ),
              ),
            )
            .toList();
    final footerItems = [
      PaneItemSeparator(),
      ..._buildPaneItemActions(),
      PaneItem(
        key: Key('/${RouteNames.setting.name}'),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () => context.goNamed(RouteNames.setting.name),
      ),
    ];

    final effectiveItems = ((items.cast<NavigationPaneItem>() + footerItems)
          ..removeWhere((final i) => i is! PaneItem || i is PaneItemAction))
        .cast<PaneItem>();

    final currentRoute = GoRouterState.of(context).uri.toString();
    final index = effectiveItems.indexWhere((final e) {
      final key = e.key;
      return key is ValueKey<String> && currentRoute == key.value;
    });

    return NavigationPane(
      selected: index != -1 ? index : null,
      items: items.cast<NavigationPaneItem>(),
      footerItems: footerItems,
      size: const NavigationPaneSize(
        openWidth: _HomeShellState._navigationPaneOpenWidth,
      ),
      autoSuggestBox: _buildAutoSuggestBox(items, controller),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
      scrollController: controller,
    );
  }

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    final select = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(runTogether)),
    );
    final override = ref.watch(
      appConfigFacadeProvider.select(
        (final value) =>
            value.obtainValue(games).currentGameConfig.separateRunOverride,
      ),
    );
    return override ?? select
        ? [
            RunAndExitPaneAction(
              key: const Key('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: _runBoth,
            ),
          ]
        : [
            RunAndExitPaneAction(
              key: const Key('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: _runMigoto,
            ),
            RunAndExitPaneAction(
              key: const Key('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: _runLauncher,
            ),
          ];
  }

  Future<void> _runBoth() async {
    await _runMigoto();
    await _runLauncher();
  }

  Future<void> _runLauncher() async {
    final launcher = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .launcherFile;
    if (launcher == null) {
      return;
    }
    await _runProgram(launcher);
  }

  Future<void> _runMigoto() async {
    final path = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .modExecFile;
    if (path == null) {
      return;
    }
    await _runProgram(path);
    if (mounted) {
      await displayInfoBarInContext(
        context,
        title: const Text('Ran 3d migoto'),
      );
    }
  }

  Future<void> _runProgram(final String path) async {
    final file = File(path);
    final pwd = file.parent.path;
    final pName = file.path.pBasename;
    await Process.run('start', ['/b', '/d', pwd, '', pName], runInShell: true);
  }

  Future<void> _saveNewWindowSize() async {
    final newSize = await WindowManager.instance.getSize();
    final newState = changeAppConfigUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      entry: windowSize,
      value: newSize,
    );
    ref.read(appConfigCProvider.notifier).update(newState);
  }
}
