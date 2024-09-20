import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../backend/fs_interface/domain/usecase/open_folder.dart';
import '../../backend/structure/entity/mod.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/app_state/column_strategy.dart';
import '../../di/structure/categories.dart';
import '../../di/structure/mods.dart';
import '../constants.dart';
import '../widget/category_drop_target.dart';
import '../widget/intrinsic_command_bar.dart';
import '../widget/mod_card.dart';
import '../widget/preset_control.dart';
import '../widget/thick_scrollbar.dart';
import '../widget/third_party/fluent_ui/auto_suggest_box.dart';
import '../widget/third_party/flutter/sliver_grid_delegates/cross_axis_aware_delegate.dart';
import '../widget/third_party/flutter/sliver_grid_delegates/fixed_count_delegate.dart'
    as s;
import '../widget/third_party/flutter/sliver_grid_delegates/max_extent_delegate.dart'
    as s;
import '../widget/third_party/flutter/sliver_grid_delegates/min_extent_delegate.dart'
    as s;

class CategoryRoute extends StatefulHookConsumerWidget {
  const CategoryRoute({required this.categoryName, super.key});

  static const _mainAxisExtent = 400.0;
  static const _mainAxisSpacing = 8.0;

  /// The category to display
  final String categoryName;

  @override
  ConsumerState<CategoryRoute> createState() => _CategoryRouteState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('categoryName', categoryName));
  }
}

class _CategoryRouteState extends ConsumerState<CategoryRoute> {
  ScrollController? scrollController;

  @override
  Widget build(final BuildContext context) {
    ref.listen(categoriesProvider, (final previous, final next) {
      final isIn = next.any((final e) => e.name == widget.categoryName);
      if (!isIn) {
        context.go(RouteNames.home.name);
      }
    });

    final category = ref
        .watch(categoriesProvider)
        .firstWhereOrNull((final e) => e.name == widget.categoryName);

    if (category == null) {
      return const SizedBox.shrink();
    }

    final sliverGridDelegate = ref.watch(columnStrategyProvider).when(
          fixedCount: (final numChildren) =>
              s.SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: CategoryRoute._mainAxisExtent,
            crossAxisCount: numChildren,
            crossAxisSpacing: CategoryRoute._mainAxisSpacing,
            mainAxisSpacing: CategoryRoute._mainAxisSpacing,
          ),
          maxExtent: (final extent) =>
              s.SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisExtent: CategoryRoute._mainAxisExtent,
            maxCrossAxisExtent: extent.toDouble(),
            crossAxisSpacing: CategoryRoute._mainAxisSpacing,
            mainAxisSpacing: CategoryRoute._mainAxisSpacing,
          ),
          minExtent: (final extent) =>
              s.SliverGridDelegateWithMinCrossAxisExtent(
            mainAxisExtent: CategoryRoute._mainAxisExtent,
            minCrossAxisExtent: extent.toDouble(),
            crossAxisSpacing: CategoryRoute._mainAxisSpacing,
            mainAxisSpacing: CategoryRoute._mainAxisSpacing,
          ),
        );

    return CategoryDropTarget(
      category: category,
      child: ScaffoldPage(
        header: _buildHeader(
          category,
          ref,
          sliverGridDelegate,
        ),
        content: _buildContent(category, sliverGridDelegate),
      ),
    );
  }

  Widget _buildHeader(
    final ModCategory category,
    final WidgetRef ref,
    final CrossAxisAwareDelegate sliverGridDelegate,
  ) {
    final context = useContext();
    return PageHeader(
      title: Text(category.name),
      commandBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PresetControlWidget(isLocal: true, category: category),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSearchBox(
              category,
              sliverGridDelegate,
            ),
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
    final CrossAxisAwareDelegate sliverGridDelegate,
  ) =>
      Consumer(
        builder: (final context, final ref, final child) {
          final data = ref.watch(modsInCategoryProvider(category));
          final items = data.indexed
              .map(
                (final e) => AutoSuggestBoxItem2(
                  value: e.$2.displayName,
                  label: e.$2.displayName,
                  onSelected: () {
                    _moveTo(e.$1, sliverGridDelegate);
                  },
                ),
              )
              .toList();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AutoSuggestBox2(
              items: items,
              trailingIcon: const Icon(FluentIcons.search),
              onSubmissionFailed: (final text) {
                if (text.isEmpty) {
                  return;
                }
                final index = data.indexWhere((final e) {
                  final name = e.displayName.toLowerCase();
                  return name.startsWith(text.toLowerCase());
                });
                _moveTo(index, sliverGridDelegate);
              },
            ),
          );
        },
      );

  Widget _buildContent(
    final ModCategory category,
    final CrossAxisAwareDelegate sliverGridDelegate,
  ) =>
      ThickScrollbar(
        child: Consumer(
          builder: (final context, final ref, final child) => _buildData(
            ref.watch(modsInCategoryProvider(category)),
            sliverGridDelegate,
          ),
        ),
      );

  Widget _buildData(
    final List<Mod> data,
    final CrossAxisAwareDelegate sliverGridDelegate,
  ) {
    final children = data.map((final e) => ModCard(mod: e)).toList();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: DynMouseScroll(
        scrollSpeed: 1,
        builder: (final context, final scrollController, final scrollPhysics) {
          this.scrollController = scrollController;
          return GridView.builder(
            controller: scrollController,
            physics: scrollPhysics,
            padding: const EdgeInsets.all(8),
            gridDelegate: sliverGridDelegate,
            itemCount: children.length,
            itemBuilder: (final context, final index) =>
                RevertScrollbar(child: children[index]),
          );
        },
      ),
    );
  }

  void _moveTo(
    final int index,
    final CrossAxisAwareDelegate sliverGridDelegate,
  ) {
    final latestCrossAxisCount = sliverGridDelegate.latestCrossAxisCount;
    if (latestCrossAxisCount == null) {
      return;
    }
    final latest = latestCrossAxisCount;
    final rowIdx = index ~/ latest;
    final distanceToMove = rowIdx *
        (CategoryRoute._mainAxisExtent + CategoryRoute._mainAxisSpacing);
    unawaited(
      scrollController?.animateTo(
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
    unawaited(
      context.push('${RouteNames.nahidastore.name}/${widget.categoryName}'),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('categoryName', widget.categoryName))
      ..add(
        DiagnosticsProperty<ScrollController?>(
          'scrollController',
          scrollController,
        ),
      );
  }
}
