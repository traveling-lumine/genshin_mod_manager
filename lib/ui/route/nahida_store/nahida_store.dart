import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/nahida_store.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/util/open_url.dart';
import 'package:genshin_mod_manager/ui/util/tag_parser.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'store_element.dart';

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
  final _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  TagParseElement? _tagFilter;

  @override
  void initState() {
    super.initState();
    ref.read(downloadModelProvider).registerDownloadCallbacks(
      onApiException: (final e) {
        if (!mounted) {
          return;
        }
        unawaited(
          displayInfoBarInContext(
            context,
            title: const Text('Download failed'),
            content: Text('${e.uri}'),
            severity: InfoBarSeverity.error,
          ),
        );
      },
      onDownloadComplete: (final element) {
        if (!mounted) {
          return;
        }
        unawaited(
          displayInfoBarInContext(
            context,
            title: Text('Downloaded ${element.title}'),
            severity: InfoBarSeverity.success,
          ),
        );
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
        } on Exception catch (e) {
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
                ref.invalidate(akashaElementProvider);
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
          onChanged: _onSearchChange,
          validator: _onValidationCheck,
        ),
      );

  Widget _buildContent() {
    final data = ref.watch(akashaElementProvider);
    final isLoading = useState(false);
    final timerReady = useState(true);
    final displayingNotSoFast = useState(false);
    print('timerReady: ${timerReady.value}, isLoading: ${isLoading.value}');
    return data.when(
      data: (final data) {
        final filteredData = data.where(_dataFilter).toList();
        return ThickScrollbar(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (final notification) {
              if (notification.metrics.extentAfter < 500 && !isLoading.value) {
                if (!timerReady.value) {
                  if (displayingNotSoFast.value) {
                    return false;
                  }
                  unawaited(
                    displayInfoBarInContext(
                      context,
                      title: const Text('Not so fast!'),
                      content: const Text(
                        'Please wait a moment before loading more data.',
                      ),
                      severity: InfoBarSeverity.warning,
                    ),
                  );
                  displayingNotSoFast.value = true;
                  Timer(
                    const Duration(seconds: 3),
                    () => displayingNotSoFast.value = false,
                  );
                  return false;
                }
                isLoading.value = true;
                timerReady.value = false;
                Timer(
                  const Duration(seconds: 3),
                  () {
                    timerReady.value = true;
                  },
                );
                unawaited(
                  ref
                      .read(akashaElementProvider.notifier)
                      .fetchNextPage()
                      .then(
                        (final _) => isLoading.value = false,
                      )
                      .catchError(
                    (final e, final stackTrace) {
                      isLoading.value = false;
                      unawaited(
                        displayInfoBarInContext(
                          context,
                          title: const Text('Failed to load data'),
                          content: Text('$e'),
                          severity: InfoBarSeverity.error,
                        ),
                      );
                      return false;
                    },
                  ),
                );
                return true;
              }
              return false;
            },
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithMinCrossAxisExtent(
                minCrossAxisExtent: 500,
                mainAxisExtent: 500,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredData.length,
              itemBuilder: (final context, final index) => RevertScrollbar(
                child: StoreElement(
                  passwordController: _textEditingController,
                  element: filteredData[index],
                  category: widget.category,
                ),
              ),
            ),
          ),
        );
      },
      error: (final e, final stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.error),
            const SizedBox(height: 8),
            Text('Failed to load data: $e'),
          ],
        ),
      ),
      loading: () => const Center(child: ProgressRing()),
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

  void _onSearchChange(final String value) {
    try {
      final filter = parseTagQuery(value);
      setState(() {
        _tagFilter = filter;
      });
    } on Exception {
      setState(() {
        _tagFilter = null;
      });
    }
  }

  bool _dataFilter(final NahidaliveElement element) {
    final tagMap = {for (final e in element.tags) e};
    final filter = _tagFilter;
    if (filter == null) {
      return true;
    }
    try {
      return filter.evaluate(tagMap);
    } on Exception {
      return true;
    }
  }
}
