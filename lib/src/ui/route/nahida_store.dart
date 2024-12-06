import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../nahida/di/nahida_store.dart';
import '../../nahida/domain/entity/nahida_element.dart';
import '../../structure/di/categories.dart';
import '../../structure/entity/mod_category.dart';
import '../constants.dart';
import '../util/debouncer.dart';
import '../util/tag_parser.dart';
import '../widget/intrinsic_command_bar.dart';
import '../widget/store_element.dart';
import '../widget/thick_scrollbar.dart';
import '../widget/third_party/flutter/sliver_grid_delegates/min_extent_delegate.dart';

class NahidaStoreRoute extends HookConsumerWidget {
  NahidaStoreRoute({required this.categoryName, super.key});
  final String categoryName;
  final _debouncer = Debouncer(const Duration(milliseconds: 700));
  final PagingController<int, NahidaliveElement?> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(categoriesProvider, (final previous, final next) {
      final isIn = next.any((final e) => e.name == categoryName);
      if (!isIn) {
        context.goNamed(RouteNames.home.name);
      }
    });

    final notifier = useState<TagParseElement?>(null);

    useEffect(
      () {
        _pagingController.addPageRequestListener(
          (final pageKey) async => _requestPage(ref, pageKey, notifier),
        );

        return _pagingController.dispose;
      },
      [_pagingController],
    );

    final initCategory = ref
        .watch(categoriesProvider)
        .firstWhere((final e) => e.name == categoryName);

    final category = useState(initCategory);

    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: Row(
          children: [
            ComboBox(
              value: category.value,
              items: ref
                  .watch(categoriesProvider)
                  .map(
                    (final e) => ComboBoxItem(value: e, child: Text(e.name)),
                  )
                  .toList(),
              onChanged: (final value) {
                if (value == null) {
                  return;
                }
                category.value = value;
              },
            ),
            const Text(' ← Akasha'),
          ],
        ),
        leading: _buildLeading(),
        commandBar: _buildCommandBar(notifier),
      ),
      content: _buildContent(category.value),
    );
  }

  Future<void> _requestPage(
    final WidgetRef ref,
    final int pageKey,
    final ValueNotifier<TagParseElement?> notifier,
  ) async {
    final List<NahidaliveElement> newItems;
    try {
      newItems =
          await ref.read(nahidaApiProvider).fetchNahidaliveElements(pageKey);
    } on Exception catch (error) {
      _pagingController.error = error;
      return;
    }

    final filteredItems = newItems
        .where((final element) => _dataFilter(notifier.value, element))
        .toList();

    if (newItems.isEmpty) {
      _pagingController.appendLastPage(filteredItems);
      return;
    }

    final nextPageKey = pageKey + 1;
    if (pageKey == 1 && filteredItems.isEmpty) {
      _pagingController.appendPage([null], nextPageKey);
      return;
    }

    _pagingController.appendPage(filteredItems, nextPageKey);
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('categoryName', categoryName));
  }

  Widget _buildCommandBar(final ValueNotifier<TagParseElement?> notifier) =>
      RepaintBoundary(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: _buildSearchBox(notifier)),
            const SizedBox(width: 16),
            _buildCommandBarCard(),
          ],
        ),
      );

  Widget _buildCommandBarCard() => IntrinsicCommandBarCard(
        child: CommandBar(
          overflowBehavior: CommandBarOverflowBehavior.clip,
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: _onRefresh,
            ),
          ],
        ),
      );

  Widget _buildContent(final ModCategory category) => ThickScrollbar(
        child: DynMouseScroll(
          scrollSpeed: 1,
          builder: (
            final context,
            final scrollController,
            final scrollPhysics,
          ) =>
              PagedGridView<int, NahidaliveElement?>(
            scrollController: scrollController,
            physics: scrollPhysics,
            key: ValueKey(_pagingController),
            pagingController: _pagingController,
            gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: 500,
              mainAxisExtent: 500,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (final context, final item, final index) {
                if (item == null) {
                  return const Center(
                    child: Text(
                      'Not found in the first page. Searching more...',
                    ),
                  );
                }
                return RevertScrollbar(
                  child: StoreElement(element: item, category: category),
                );
              },
            ),
          ),
        ),
      );

  Widget? _buildLeading() {
    final context = useContext();
    return context.canPop()
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: RepaintBoundary(
              child: IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: context.pop,
              ),
            ),
          )
        : null;
  }

  Widget _buildSearchBox(final ValueNotifier<TagParseElement?> notifier) {
    final context = useContext();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextFormBox(
        autovalidateMode: AutovalidateMode.always,
        placeholder: AppLocalizations.of(context)!.searchTags,
        onChanged: (final value) {
          _onSearchChange(notifier, value);
        },
        validator: _onValidationCheck,
      ),
    );
  }

  bool _dataFilter(
    final TagParseElement? tagFilter,
    final NahidaliveElement element,
  ) {
    final tagMap = {for (final e in element.tags) e};
    if (tagFilter == null) {
      return true;
    }
    try {
      final bool = tagFilter(tagMap);
      return bool;
    } on Exception {
      return true;
    }
  }

  void _onRefresh() {
    _pagingController.refresh();
  }

  void _onSearchChange(
    final ValueNotifier<TagParseElement?> notifier,
    final String value,
  ) {
    TagParseElement? filter;
    try {
      filter = parseTagQuery(value);
    } on Exception {
      filter = null;
    }
    _debouncer(() {
      notifier.value = filter;
      _pagingController.refresh();
    });
  }

  String? _onValidationCheck(final String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      parseTagQuery(value);
    } on Exception catch (e) {
      return e.toString();
    }
    return null;
  }
}
