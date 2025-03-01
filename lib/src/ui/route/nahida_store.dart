import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l1/di/categories.dart';
import '../../l10n/app_localizations.dart';
import '../../nahida/l0/entity/nahida_element.dart';
import '../../nahida/l0/usecase/get_element_page.dart';
import '../../nahida/l1/di/nahida_repo.dart';
import '../util/debouncer.dart';
import '../util/tag_parser.dart';
import '../widget/intrinsic_command_bar.dart';
import '../widget/store_element.dart';
import '../widget/thick_scrollbar.dart';
import '../widget/third_party/flutter/sliver_grid_delegates/min_extent_delegate.dart';

class NahidaStoreRoute extends StatefulHookConsumerWidget {
  const NahidaStoreRoute({required this.category, super.key});
  final ModCategory category;

  @override
  ConsumerState<NahidaStoreRoute> createState() => _NahidaStoreRouteState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}

class _NahidaStoreRouteState extends ConsumerState<NahidaStoreRoute> {
  final _debouncer = Debouncer(const Duration(milliseconds: 700));
  TagParseElement? _tagFilter;
  late ModCategory _category = widget.category;
  late final PagingController<int, NahidaliveElement?> _pagingController =
      PagingController(firstPageKey: 1)..addPageRequestListener(_requestPage);

  @override
  Widget build(final BuildContext context) => ScaffoldPage.withPadding(
        header: PageHeader(
          title: Row(
            children: [
              ComboBox(
                value: _category,
                items: ref
                    .watch(categoriesProvider)
                    .requireValue
                    .map(
                      (final e) => ComboBoxItem(value: e, child: Text(e.name)),
                    )
                    .toList(),
                onChanged: (final value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _category = value;
                  });
                },
              ),
              const Text(' ← Akasha'),
            ],
          ),
          leading: _buildLeading(),
          commandBar: _buildCommandBar(),
        ),
        content: _buildContent(),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<ModCategory>('category', widget.category));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Widget _buildCommandBar() => RepaintBoundary(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: _buildSearchBox()),
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

  Widget _buildContent() => ThickScrollbar(
        child: DynMouseScroll(
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
                  child: StoreElement(element: item, category: _category),
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

  Widget _buildSearchBox() {
    final context = useContext();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextFormBox(
        autovalidateMode: AutovalidateMode.always,
        placeholder: AppLocalizations.of(context)!.searchTags,
        onChanged: _onSearchChange,
        validator: _onValidationCheck,
      ),
    );
  }

  bool _dataFilter(
    final NahidaliveElement element,
  ) {
    final tagMap = {for (final e in element.tags) e};
    final tagFilter = _tagFilter;
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
    final String value,
  ) {
    TagParseElement? filter;
    try {
      filter = parseTagQuery(value);
    } on Exception {
      filter = null;
    }
    _debouncer(() {
      setState(() {
        _tagFilter = filter;
      });
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

  Future<void> _requestPage(
    final int pageKey,
  ) async {
    final List<NahidaliveElement> newItems;
    try {
      newItems = await getNahidaElementPageUseCase(
        repository: ref.read(nahidaRepositoryProvider),
        pageNum: pageKey,
      );
    } on Exception catch (error) {
      _pagingController.error = error;
      return;
    }
    if (newItems.isEmpty) {
      _pagingController.appendLastPage(newItems);
      return;
    }

    final filteredItems = newItems.where(_dataFilter).toList();

    final nextPageKey = pageKey + 1;
    if (pageKey == 1 && filteredItems.isEmpty) {
      _pagingController.appendPage([null], nextPageKey);
      return;
    }

    _pagingController.appendPage(filteredItems, nextPageKey);
  }
}
