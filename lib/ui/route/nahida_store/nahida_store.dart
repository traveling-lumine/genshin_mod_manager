import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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

class NahidaStoreRoute extends StatelessWidget {
  const NahidaStoreRoute({required this.category, super.key});

  final ModCategory category;

  @override
  Widget build(final BuildContext context) => ChangeNotifierProvider(
        create: (final context) => createViewModel(
          observer: context.read(),
        ),
        child: _NahidaStoreRoute(category: category),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}

class _NahidaStoreRoute extends StatefulWidget {
  const _NahidaStoreRoute({required this.category});

  final ModCategory category;

  @override
  State<_NahidaStoreRoute> createState() => _NahidaStoreRouteState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}

class _NahidaStoreRouteState extends State<_NahidaStoreRoute> {
  final _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  TagParseElement? _tagFilter;

  @override
  void initState() {
    super.initState();
    context.read<NahidaStoreViewModel>().registerDownloadCallbacks(
      onApiException: (final e) {
        if (!mounted) {
          return;
        }
        unawaited(displayInfoBarInContext(
          context,
          title: const Text('Download failed'),
          content: Text('${e.uri}'),
          severity: InfoBarSeverity.error,
        ));
      },
      onDownloadComplete: (final element) {
        if (!mounted) {
          return;
        }
        unawaited(displayInfoBarInContext(
          context,
          title: Text('Downloaded ${element.title}'),
          severity: InfoBarSeverity.success,
        ));
      },
      onPasswordRequired: (final wrongPw) {
        if (!mounted) {
          return Future(() => null);
        }
        return showDialog(
          context: context,
          builder: (final dialogContext) => ContentDialog(
            title: const Text('Enter password'),
            content: IntrinsicHeight(
              child: TextFormBox(
                autovalidateMode: AutovalidateMode.always,
                autofocus: true,
                controller: _textEditingController,
                placeholder: 'Password',
                onFieldSubmitted: (final value) => Navigator.of(dialogContext)
                    .pop(_textEditingController.text),
                validator: (final value) {
                  if (wrongPw == null || value == null) {
                    return null;
                  }
                  if (value == wrongPw) {
                    return "Wrong password";
                  }
                  return null;
                },
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
      onExtractFail: (final category, final modName, final data) async {
        if (mounted) {
          unawaited(
            displayInfoBarInContext(
              context,
              title: const Text('Download failed'),
              content: Text('Failed to extract archive: decode error.'
                  ' Instead, the archive was saved as $modName.'),
              severity: InfoBarSeverity.error,
            ),
          );
        }
        try {
          await File(category.path.pJoin(modName)).writeAsBytes(data);
        } catch (e) {
          if (!mounted) {
            return;
          }
          unawaited(
            displayInfoBarInContext(
              context,
              title: const Text('Write failed'),
              content: Text('Failed to write archive $modName: $e'),
              severity: InfoBarSeverity.error,
            ),
          );
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
  Widget build(final BuildContext context) => ScaffoldPage.withPadding(
        header: PageHeader(
          title: Text('${widget.category.name} ← Akasha'),
          leading: _buildLeading(),
          commandBar: _buildCommandBar(),
        ),
        content: _buildContent(),
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

  Widget _buildSearchBox() => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: TextFormBox(
          autovalidateMode: AutovalidateMode.always,
          placeholder: 'Search tags',
          onChanged: (final value) {
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
          validator: (final value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            try {
              parseTagQuery(value);
            } catch (e) {
              return e.toString();
            }
            return null;
          },
        ),
      );

  Widget _buildContent() =>
      Selector<NahidaStoreViewModel, Future<List<NahidaliveElement>>>(
        selector: (final context, final model) => model.elements,
        builder: (final context, final elements, final child) => FutureBuilder(
          future: elements,
          builder: (final context, final snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: ProgressRing());
            }
            if (!snapshot.hasData) {
              return Text('Unable to fetch data.'
                  ' Report this to the developer: $snapshot');
            }
            final data = snapshot.data!.where((final element) {
              final tagMap = {for (final e in element.tags) e: true};
              try {
                final filter = _tagFilter;
                if (filter == null) {
                  return true;
                }
                return filter.evaluate(tagMap);
              } catch (e) {
                return true;
              }
            }).toList();
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
                itemBuilder: (final context, final index) => RevertScrollbar(
                  child: StoreElement(
                    passwordController: _textEditingController,
                    element: data[index],
                    category: widget.category,
                  ),
                ),
              ),
            );
          },
        ),
      );
}
