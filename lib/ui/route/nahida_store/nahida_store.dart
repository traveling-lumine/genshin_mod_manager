import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store/nahida_store_vm.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store/store_element.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/util/tag_parser.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NahidaStoreRoute extends StatelessWidget {
  final ModCategory category;

  const NahidaStoreRoute({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => createNahidaliveAPI()),
        ChangeNotifierProvider(
          create: (context) => createViewModel(
            api: context.read(),
            observer: context.read(),
          ),
        ),
      ],
      child: _NahidaStoreRoute(category: category),
    );
  }
}

class _NahidaStoreRoute extends StatefulWidget {
  final ModCategory category;

  const _NahidaStoreRoute({required this.category});

  @override
  State<_NahidaStoreRoute> createState() => _NahidaStoreRouteState();
}

class _NahidaStoreRouteState extends State<_NahidaStoreRoute> {
  final _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  TagParseElement? _tagFilter;

  @override
  void initState() {
    super.initState();
    final vm = context.read<NahidaStoreViewModel>();
    vm.registerDownloadCallbacks(
      onApiException: (e) {
        if (!mounted) return;
        displayInfoBarInContext(
          context,
          title: const Text('Download failed'),
          content: Text('${e.uri}'),
          severity: InfoBarSeverity.error,
        );
      },
      onDownloadComplete: (element) {
        if (!mounted) return;
        displayInfoBarInContext(
          context,
          title: Text('Downloaded ${element.title}'),
          severity: InfoBarSeverity.success,
        );
      },
      onPasswordRequired: () {
        if (!mounted) return Future(() => null);
        return showDialog(
          context: context,
          builder: (dialogContext) => ContentDialog(
            title: const Text('Enter password'),
            content: SizedBox(
              height: 40,
              child: TextBox(
                autofocus: true,
                controller: _textEditingController,
                placeholder: 'Password',
                onSubmitted: (value) => Navigator.of(dialogContext)
                    .pop(_textEditingController.text),
              ),
            ),
            actions: [
              Button(
                onPressed: Navigator.of(dialogContext).pop,
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext)
                    .pop(_textEditingController.text),
                child: const Text('Download'),
              ),
            ],
          ),
        );
      },
      onExtractFail: (category, modName, data) async {
        if (mounted) {
          unawaited(displayInfoBarInContext(
            context,
            title: const Text('Download failed'),
            content: Text('Failed to extract archive: decode error.'
                ' Instead, the archive was saved as $modName.'),
            severity: InfoBarSeverity.error,
          ));
        }
        try {
          await File(category.path.pJoin(modName)).writeAsBytes(data);
        } catch (e) {
          if (!mounted) return;
          unawaited(displayInfoBarInContext(
            context,
            title: const Text('Write failed'),
            content: Text('Failed to write archive $modName: $e'),
            severity: InfoBarSeverity.error,
          ));
        }
      },
    );
  }

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
        leading: _buildLeading(),
        commandBar: _buildCommandBar(),
      ),
      content: _buildContent(),
    );
  }

  Widget? _buildLeading() => context.canPop()
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

  Widget _buildCommandBarCard() {
    return IntrinsicCommandBarCard(
      child: CommandBar(
        overflowBehavior: CommandBarOverflowBehavior.clip,
        mainAxisAlignment: MainAxisAlignment.end,
        primaryItems: [
          CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            onPressed: () {
              context.read<NahidaStoreViewModel>().onRefresh();
              setState(() {
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
    return Selector<NahidaStoreViewModel, Future<List<NahidaliveElement>>>(
      selector: (context, model) => model.elements,
      builder: (context, elements, child) {
        return FutureBuilder(
          future: elements,
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
      },
    );
  }
}
