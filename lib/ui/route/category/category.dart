import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/mod_switcher.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/mod_writer.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/flow/category.dart';
import 'package:genshin_mod_manager/flow/ini_widget.dart';
import 'package:genshin_mod_manager/flow/mod_card.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:window_manager/window_manager.dart';

part 'ini_widget.dart';
part 'mod_card.dart';

/// A route that displays a category of mods
class CategoryRoute extends HookWidget {
  /// Creates a [CategoryRoute].
  const CategoryRoute({required this.category, super.key});

  static const _mainAxisExtent = 400.0;
  static const _mainAxisSpacing = 8.0;
  static final _sliverGridDelegateWithMinCrossAxisExtent =
      SliverGridDelegateWithMinCrossAxisExtent(
    mainAxisExtent: _mainAxisExtent,
    minCrossAxisExtent: 440,
    crossAxisSpacing: 8,
    mainAxisSpacing: _mainAxisSpacing,
  );

  /// The category to display
  final ModCategory category;

  @override
  Widget build(final BuildContext context) {
    final scrollController = useScrollController();
    return CategoryDropTarget(
      category: category,
      child: ScaffoldPage(
        header: _buildHeader(scrollController),
        content: _buildContent(scrollController),
      ),
    );
  }

  Widget _buildHeader(final ScrollController scrollController) {
    final context = useContext();
    return PageHeader(
      title: Text(category.name),
      commandBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PresetControlWidget(
            isLocal: true,
            category: category,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSearchBox(scrollController),
          ),
          IntrinsicCommandBarCard(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.clip,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.folder_open),
                  onPressed: _onFolderOpen,
                ),
                CommandBarButton(
                  icon: const Icon(FluentIcons.download),
                  onPressed: () => _onDownloadPressed(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(final ScrollController scrollController) => Consumer(
        builder: (final context, final ref, final child) {
          final whenOrNull =
              ref.watch(categoryWatcherProvider(category)).whenOrNull(
            data: (final data) {
              final items = data.indexed.map(
                (final e) => AutoSuggestBoxItem2(
                  value: e.$2.displayName,
                  label: e.$2.displayName,
                  onSelected: () {
                    _moveTo(scrollController, e.$1);
                  },
                ),
              );
              return AutoSuggestBox2(
                items: items.toList(),
                trailingIcon: const Icon(FluentIcons.search),
                onSubmissionFailed: (final text) {
                  if (text.isEmpty) {
                    return;
                  }
                  final index = data.indexWhere((final e) {
                    final name = e.displayName.toLowerCase();
                    return name.startsWith(text.toLowerCase());
                  });
                  _moveTo(scrollController, index);
                },
              );
            },
          );
          if (whenOrNull == null) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: whenOrNull,
          );
        },
      );

  Widget _buildContent(final ScrollController scrollController) =>
      ThickScrollbar(
        child: Consumer(
          builder: (final context, final ref, final child) =>
              ref.watch(categoryWatcherProvider(category)).when(
                    skipLoadingOnReload: true,
                    data: (final data) => _buildData(data, scrollController),
                    error: _buildError,
                    loading: _buildLoading,
                  ),
        ),
      );

  Widget _buildData(
    final List<Mod> data,
    final ScrollController scrollController,
  ) {
    final children = data.map((final e) => _ModCard(mod: e)).toList();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: _sliverGridDelegateWithMinCrossAxisExtent,
        itemCount: children.length,
        itemBuilder: (final context, final index) =>
            RevertScrollbar(child: children[index]),
      ),
    );
  }

  Widget _buildError(final Object error, final StackTrace stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.error),
            Text('Error: $error\n$stackTrace'),
          ],
        ),
      );

  Widget _buildLoading() => const AnimatedSwitcher(
        duration: Duration.zero,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );

  void _moveTo(final ScrollController scrollController, final int index) {
    final latestCrossAxisCount =
        _sliverGridDelegateWithMinCrossAxisExtent.latestCrossAxisCount;
    if (latestCrossAxisCount == null) {
      return;
    }
    final latest = latestCrossAxisCount;
    final rowIdx = index ~/ latest;
    final distanceToMove = rowIdx * (_mainAxisExtent + _mainAxisSpacing);
    unawaited(
      scrollController.animateTo(
        distanceToMove,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onFolderOpen() {
    openFolder(category.path);
  }

  void _onDownloadPressed(final BuildContext context) => unawaited(
        context.push(kNahidaStoreRoute, extra: category),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}
