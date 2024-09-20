import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../backend/akasha/domain/entity/nahida_element.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/nahida_store.dart';
import '../../di/structure/categories.dart';
import '../constants.dart';
import '../util/tag_parser.dart';
import '../widget/intrinsic_command_bar.dart';
import '../widget/store_element.dart';
import '../widget/thick_scrollbar.dart';
import '../widget/third_party/flutter/sliver_grid_delegates/min_extent_delegate.dart';

class NahidaStoreRoute extends StatefulHookConsumerWidget {
  const NahidaStoreRoute({required this.categoryName, super.key});
  final String categoryName;

  @override
  ConsumerState<NahidaStoreRoute> createState() => _NahidaStoreRouteState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('categoryName', categoryName));
  }
}

class _Debouncer {
  _Debouncer(this.duration);
  final Duration duration;

  Timer? _timer;

  void call(final VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}

class _NahidaStoreRouteState extends ConsumerState<NahidaStoreRoute> {
  TagParseElement? _tagFilter;
  final _debouncer = _Debouncer(const Duration(milliseconds: 700));

  final PagingController<int, NahidaliveElement?> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  Widget build(final BuildContext context) {
    ref.listen(
      categoriesProvider,
      (final previous, final next) {
        final isIn = next.any((final e) => e.name == widget.categoryName);
        if (!isIn) {
          context.go(RouteNames.home.name);
        }
      },
    );

    final initCategory = ref.watch(categoriesProvider).firstWhere(
          (final e) => e.name == widget.categoryName,
        );

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
                    (final e) => ComboBoxItem(
                      value: e,
                      child: Text(e.name),
                    ),
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
        commandBar: _buildCommandBar(),
      ),
      content: _buildContent(category.value),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
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

  Widget _buildContent(final ModCategory category) => ThickScrollbar(
        child: PagedGridView<int, NahidaliveElement?>(
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
                  child: Text('Not found in the first page. Searching more...'),
                );
              }
              return RevertScrollbar(
                child: StoreElement(
                  element: item,
                  category: category,
                ),
              );
            },
          ),
        ),
      );

  Widget? _buildLeading() => context.canPop()
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

  Widget _buildSearchBox() => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: TextFormBox(
          autovalidateMode: AutovalidateMode.always,
          placeholder: AppLocalizations.of(context)!.searchTags,
          onChanged: _onSearchChange,
          validator: _onValidationCheck,
        ),
      );

  bool _dataFilter(final NahidaliveElement element) {
    final tagMap = {for (final e in element.tags) e};
    final filter = _tagFilter;
    if (filter == null) {
      return true;
    }
    try {
      return filter(tagMap);
    } on Exception {
      return true;
    }
  }

  Future<void> _fetchPage(final int pageKey) async {
    try {
      final newItems =
          await ref.read(akashaApiProvider).fetchNahidaliveElements(pageKey);
      final isLastPage = newItems.isEmpty;
      List<NahidaliveElement?> filteredItems =
          newItems.where(_dataFilter).toList();
      if (newItems.isNotEmpty && filteredItems.isEmpty && pageKey == 1) {
        filteredItems = [null];
      }
      if (isLastPage) {
        _pagingController.appendLastPage(filteredItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(filteredItems, nextPageKey);
      }
    } on Exception catch (error) {
      _pagingController.error = error;
    }
  }

  void _onRefresh() {
    _pagingController.refresh();
  }

  void _onSearchChange(final String value) {
    TagParseElement? filter;
    try {
      filter = parseTagQuery(value);
    } on Exception {
      filter = null;
    }
    _debouncer(
      () {
        setState(() {
          _tagFilter = filter;
          _pagingController.refresh();
        });
      },
    );
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
