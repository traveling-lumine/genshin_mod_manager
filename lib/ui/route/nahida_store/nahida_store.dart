import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/upstream/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/category.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store/store_element.dart';
import 'package:genshin_mod_manager/ui/util/tag_parser.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';

class NahidaStoreRoute extends StatefulWidget {
  final ModCategory category;

  const NahidaStoreRoute({super.key, required this.category});

  @override
  State<NahidaStoreRoute> createState() => _NahidaStoreRouteState();
}

class _NahidaStoreRouteState extends State<NahidaStoreRoute> {
  final _api = NahidaliveAPI();
  final _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  TagParseElement? _tagFilter;
  late Future<List<NahidaliveElement>> future = _api.fetchNahidaliveElements();

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: Text('${widget.category.name} ← Akasha'),
        leading: _buildLeading(context),
        commandBar: _buildCommandBar(),
      ),
      content: _buildContent(),
    );
  }

  Widget? _buildLeading(BuildContext context) => context.canPop()
      ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: RepaintBoundary(
            child: IconButton(
              icon: const Icon(FluentIcons.back),
              onPressed: context.pop,
            ),
          ),
        )
      : null;

  Widget _buildCommandBar() {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(child: _buildSearchBox()),
          const SizedBox(width: 16),
          _buildCommandBarCard(),
        ],
      ),
    );
  }

  IntrinsicCommandBarCard _buildCommandBarCard() {
    return IntrinsicCommandBarCard(
      child: CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.clip,
        mainAxisAlignment: MainAxisAlignment.end,
        primaryItems: [
          CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            onPressed: () {
              setState(() {
                future = _api.fetchNahidaliveElements();
                final prevController = _scrollController;
                _scrollController = ScrollController(
                  initialScrollOffset: prevController.offset,
                );
                prevController.dispose();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextFormBox(
        autovalidateMode: AutovalidateMode.always,
        placeholder: 'Search tags',
        onChanged: (value) {
          try {
            final filter = parseTagQuery(value);
            setState(() {
              _tagFilter = filter;
            });
          } catch (e) {
            setState(() {
              _tagFilter = null;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          try {
            parseTagQuery(value);
          } catch (e) {
            return e.toString();
          }
          return null;
        },
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: ProgressRing());
        }
        if (snapshot.hasData) {
          final data = snapshot.data!.where((element) {
            final tagMap = {for (var e in element.tags) e: true};
            try {
              final filter = _tagFilter;
              if (filter == null) return true;
              return filter.evaluate(tagMap);
            } catch (e) {
              return true;
            }
          }).toList(growable: false);
          return ThickScrollbar(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
                minCrossAxisExtent: 500,
                mainAxisExtent: 500,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) => RevertScrollbar(
                child: StoreElement(
                  passwordController: _textEditingController,
                  element: data[index],
                  api: _api,
                  category: widget.category,
                ),
              ),
            ),
          );
        }
        return Text('Unable to fetch data.'
            ' Report this to the developer: $snapshot');
      },
    );
  }
}
