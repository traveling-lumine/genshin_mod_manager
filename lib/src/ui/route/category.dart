import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/fs_interface/domain/usecase/open_folder.dart';
import '../../backend/structure/entity/mod.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/fs_watcher.dart';
import '../route_names.dart';
import '../widget/category_drop_target.dart';
import '../widget/intrinsic_command_bar.dart';
import '../widget/mod_card.dart';
import '../widget/preset_control.dart';
import '../widget/thick_scrollbar.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';
import '../widget/third_party/flutter/min_extent_delegate.dart';

class CategoryRoute extends HookConsumerWidget {
  const CategoryRoute({required this.categoryName, super.key});

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
  final String categoryName;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
      categoriesProvider,
      (final previous, final next) {
        final isIn = next.any((final e) => e.name == categoryName);
        if (!isIn) {
          context.go(RouteNames.home.name);
        }
      },
    );

    final scrollController = useScrollController();
    final category = ref.watch(categoriesProvider).firstWhereOrNull(
          (final e) => e.name == categoryName,
        );

    if (category == null) {
      return const SizedBox.shrink();
    }

    return CategoryDropTarget(
      category: category,
      child: ScaffoldPage(
        header: _buildHeader(category, scrollController, ref),
        content: _buildContent(category, scrollController),
      ),
    );
  }

  Widget _buildHeader(
    final ModCategory category,
    final ScrollController scrollController,
    final WidgetRef ref,
  ) {
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
            child: _buildSearchBox(category, scrollController),
          ),
          IntrinsicCommandBarCard(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.clip,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.folder_open),
                  onPressed: () async => _onFolderOpen(category),
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

  Widget _buildSearchBox(
    final ModCategory category,
    final ScrollController scrollController,
  ) =>
      Consumer(
        builder: (final context, final ref, final child) {
          final whenOrNull =
              ref.watch(modsInCategoryProvider(category)).whenOrNull(
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

  Widget _buildContent(
    final ModCategory category,
    final ScrollController scrollController,
  ) =>
      ThickScrollbar(
        child: Consumer(
          builder: (final context, final ref, final child) =>
              ref.watch(modsInCategoryProvider(category)).when(
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
    final children = data.map((final e) => ModCard(mod: e)).toList();
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
              Text('Collecting mods...'),
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

  Future<void> _onFolderOpen(final ModCategory category) async {
    await openFolderUseCase(category.path);
  }

  void _onDownloadPressed(final BuildContext context) {
    unawaited(context.push('${RouteNames.nahidastore.name}/$categoryName'));
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('categoryName', categoryName));
  }
}
