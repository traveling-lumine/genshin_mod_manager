import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

import '../../backend/fs_interface/helper/path_op_string.dart';
import '../../di/app_state/current_target_game.dart';
import '../../di/app_state/game_config.dart';
import '../../di/app_state/games_list.dart';
import '../../di/app_state/run_together.dart';
import '../../di/app_state/separate_run_override.dart';
import '../../di/app_state/window_size.dart';
import '../../di/app_version/is_outdated.dart';
import '../../di/exe_arg.dart';
import '../../di/structure/categories.dart';
import '../constants.dart';
import '../util/display_infobar.dart';
import '../widget/appbar.dart';
import '../widget/category_pane_item.dart';
import '../widget/download_queue.dart';
import '../widget/protocol_handler.dart';
import '../widget/run_pane.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';
import '../widget/update_popup.dart';

class HomeShell extends StatefulHookConsumerWidget {
  const HomeShell({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState<T extends StatefulWidget> extends ConsumerState<HomeShell>
    with WindowListener, ProtocolListener {
  static const _navigationPaneOpenWidth = 270.0;
  final _flyoutController = FlyoutController();

  @override
  Widget build(final BuildContext context) {
    ref.listen(gamesListProvider, (final previous, final next) {
      if (next.isEmpty) {
        context.go(RouteNames.firstpage.name);
      }
    });

    final game = ref.watch(targetGameProvider);
    final updateMarker = (ref.watch(isOutdatedProvider).valueOrNull ?? false)
        ? AppLocalizations.of(context)!.updateMarker
        : '';
    return UpdatePopup(
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
    );
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    protocolHandler.removeListener(this);
    _flyoutController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    WindowManager.instance.addListener(this);

    final read = ref.read(windowSizeProvider);
    if (read != null) {
      unawaited(WindowManager.instance.setSize(read));
    }
  }

  @override
  void onProtocolUrlReceived(final String url) {
    ref.read(argProviderProvider.notifier).add(url);
  }

  @override
  void onWindowFocus() {
    ref.invalidate(categoriesProvider);
  }

  @override
  void onWindowResized() {
    super.onWindowResized();
    unawaited(
      WindowManager.instance
          .getSize()
          .then(ref.read(windowSizeProvider.notifier).setValue),
    );
  }

  Widget _buildAutoSuggestBox(final List<FolderPaneItem> items) =>
      AutoSuggestBox2(
        items: items
            .map(
              (final e) => AutoSuggestBoxItem2(
                value: e.category,
                label: e.category.name,
              ),
            )
            .toList(),
        trailingIcon: const Icon(FluentIcons.search),
        onSelected: (final item) {
          final category = item.value;
          if (category == null) {
            return;
          }
          context.go('${RouteNames.category.name}/${category.name}');
        },
        onSubmissionFailed: (final text) {
          if (text.isEmpty) {
            return;
          }
          final item = items.firstWhereOrNull((final e) {
            final name = e.category.name.toLowerCase();
            return name.startsWith(text.toLowerCase());
          });
          if (item == null) {
            return;
          }
          final category = item.category;
          context.go('${RouteNames.category.name}/${category.name}');
        },
      );

  NavigationPane _buildPane() {
    final items = ref
        .watch(categoriesProvider)
        .map(
          (final e) => FolderPaneItem(
            category: e,
            key: Key('${RouteNames.category.name}/${e.name}'),
            onTap: () => context.go('${RouteNames.category.name}/${e.name}'),
          ),
        )
        .toList();
    final footerItems = [
      PaneItemSeparator(),
      ..._buildPaneItemActions(),
      PaneItem(
        key: Key(RouteNames.setting.name),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SizedBox.shrink(),
        onTap: () => context.go(RouteNames.setting.name),
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
      autoSuggestBox: _buildAutoSuggestBox(items),
      autoSuggestBoxReplacement: const Icon(FluentIcons.search),
    );
  }

  List<PaneItemAction> _buildPaneItemActions() {
    const icon = Icon(FluentIcons.user_window);
    final select = ref.watch(runTogetherProvider);
    final override = ref.watch(separateRunOverrideProvider);
    return override ?? select
        ? [
            RunAndExitPaneAction(
              key: const Key('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: _runBoth,
              flyoutController: _flyoutController,
            ),
          ]
        : [
            RunAndExitPaneAction(
              key: const Key('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: _runMigoto,
              flyoutController: _flyoutController,
            ),
            RunAndExitPaneAction(
              key: const Key('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: _runLauncher,
              flyoutController: _flyoutController,
            ),
          ];
  }

  Future<void> _runBoth() async {
    await _runMigoto();
    await _runLauncher();
  }

  Future<void> _runLauncher() async {
    final launcher = ref.read(gameConfigNotifierProvider).launcherFile;
    if (launcher == null) {
      return;
    }
    await _runProgram(launcher);
  }

  Future<void> _runMigoto() async {
    final path = ref.read(gameConfigNotifierProvider).modExecFile;
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
}

Future<void> _runProgram(final String path) async {
  final file = File(path);
  final pwd = file.parent.path;
  final pName = file.path.pBasename;
  await Process.run('start', ['/b', '/d', pwd, '', pName], runInShell: true);
}
