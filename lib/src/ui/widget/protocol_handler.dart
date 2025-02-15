import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l1/di/exe_arg.dart';
import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l1/di/categories.dart';
import '../../nahida/l0/di/nahida_download_queue.dart';
import '../../nahida/l0/entity/nahida_element.dart';
import '../../nahida/l0/usecase/download_url.dart';
import '../../nahida/l0/usecase/get_element.dart';
import '../../nahida/l1/di/nahida_repo.dart';
import 'turnstile_dialog.dart';

String _convertUuid(final String uuid) {
  // if uuid has no dashes, add it manually
  if (uuid.length == 32) {
    final sb = StringBuffer()
      ..writeAll(
        [
          uuid.substring(0, 8),
          uuid.substring(8, 12),
          uuid.substring(12, 16),
          uuid.substring(16, 20),
          uuid.substring(20, 32),
        ],
        '-',
      );
    return sb.toString();
  }
  return uuid;
}

Future<NahidaliveElement> _getElement(
  final WidgetRef ref,
  final String rawUuid,
) async =>
    getNahidaElementUseCase(
      repository: ref.read(nahidaRepositoryProvider),
      uuid: _convertUuid(rawUuid),
    );

typedef VoidFutureCallback = Future<void> Function();

class ProtocolHandlerWidget extends ConsumerWidget {
  const ProtocolHandlerWidget({
    required this.child,
    required this.runMigotoCallback,
    required this.runLauncherCallback,
    required this.runBothCallback,
    super.key,
  });
  final Widget child;
  final VoidFutureCallback runMigotoCallback;
  final VoidFutureCallback runLauncherCallback;
  final VoidFutureCallback runBothCallback;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
      argProviderProvider,
      (final previous, final next) => _argListener(context, ref, next),
    );
    return child;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<VoidFutureCallback>.has(
          'runMigotoCallback',
          runMigotoCallback,
        ),
      )
      ..add(
        ObjectFlagProperty<VoidFutureCallback>.has(
          'runLauncherCallback',
          runLauncherCallback,
        ),
      )
      ..add(
        ObjectFlagProperty<VoidFutureCallback>.has(
          'runBothCallback',
          runBothCallback,
        ),
      );
  }

  void _argListener(
    final BuildContext context,
    final WidgetRef ref,
    final AsyncValue<String> next,
  ) {
    final data = next.valueOrNull;
    if (data == null) {
      return;
    }
    if (data == AcceptedArg.run3dm.cmd) {
      unawaited(runMigotoCallback());
    } else if (data == AcceptedArg.rungame.cmd) {
      unawaited(runLauncherCallback());
    } else if (data == AcceptedArg.runboth.cmd) {
      unawaited(runBothCallback());
    } else if (data.startsWith('/')) {
      unawaited(_showInvalidCommandDialog(context, data));
    } else {
      unawaited(_onUriInput(context, ref, data));
    }
  }

  Future<void> _onUriInput(
    final BuildContext context,
    final WidgetRef ref,
    final String url,
  ) async {
    final parsed = Uri.parse(url);
    final rawUuid = parsed.queryParameters['uuid'];
    if (rawUuid == null) {
      return;
    }

    final password = parsed.queryParameters['pw'];
    final categoryName = GoRouterState.of(context).pathParameters['category'];
    final category = ref
        .read(categoriesProvider)
        .requireValue
        .firstWhereOrNull((final e) => e.name == categoryName);

    _showProtocolConfirmDialog(context, url, rawUuid, category, password);
  }

  Future<void> _showInvalidCommandDialog(
    final BuildContext context,
    final String arg,
  ) =>
      showDialog(
        context: context,
        builder: (final dCtx) {
          final validArgs =
              AcceptedArg.values.map((final e) => e.cmd).join(', ');
          return ContentDialog(
            title: const Text('Invalid argument'),
            content: Text('Unknown argument: $arg.\n'
                'Valid args are: $validArgs'),
            actions: [
              FilledButton(
                onPressed: Navigator.of(dCtx).pop,
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

  void _showProtocolConfirmDialog(
    final BuildContext context,
    final String url,
    final String rawUuid,
    final ModCategory? category,
    final String? password,
  ) =>
      unawaited(
        showDialog(
          context: context,
          builder: (final dCtx) => _ProtocolDialog(
            url: url,
            rawUuid: rawUuid,
            initialCategory: category,
            password: password,
          ),
        ),
      );
}

class _ProtocolDialog extends HookConsumerWidget {
  const _ProtocolDialog({
    required this.url,
    required this.rawUuid,
    required this.initialCategory,
    this.password,
  });
  final String url;
  final String rawUuid;
  final String? password;
  final ModCategory? initialCategory;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final memoizedFuture =
        // Using future itself
        // ignore: discarded_futures
        useMemoized(() => Future(() async => _getElement(ref, rawUuid)));
    final elemGetState = useFuture(memoizedFuture);

    final categories = ref.watch(categoriesProvider);
    final currentSelected = useState<ModCategory?>(initialCategory);
    final value = currentSelected.value;

    return ContentDialog(
      title: const Text('Protocol URL received'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (elemGetState.hasError)
            const Text('Error fetching element')
          else if (elemGetState.hasData)
            Text('Download ${elemGetState.requireData.title}')
          else
            const Text('Fetching element...'),
          const SizedBox(height: 10),
          _buildCategorySelector(currentSelected, categories.requireValue),
        ],
      ),
      actions: [
        Button(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: elemGetState.hasData && value != null
              ? () async =>
                  _onConfirm(ref, value, context, elemGetState.requireData)
              : null,
          child: Text(
            elemGetState.hasError
                ? 'Error: ${elemGetState.error.runtimeType}'
                : value == null
                    ? 'Select a category First'
                    : elemGetState.hasData
                        ? 'Download'
                        : 'Loading...',
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('url', url))
      ..add(StringProperty('rawUuid', rawUuid))
      ..add(
        DiagnosticsProperty<ModCategory?>('initialCategory', initialCategory),
      )
      ..add(StringProperty('password', password));
  }

  Widget _buildCategorySelector(
    final ValueNotifier<ModCategory?> currentSelected,
    final List<ModCategory> categories,
  ) {
    const emptyPlaceholder = '';
    return IntrinsicHeight(
      child: EditableComboBox<String>(
        value: currentSelected.value?.name ?? emptyPlaceholder,
        items: categories
            .map(
              (final e) => ComboBoxItem(value: e.name, child: Text(e.name)),
            )
            .toList(),
        onChanged: (final value) {
          final category = _getCategory(categories, value);
          currentSelected.value = category;
        },
        onFieldSubmitted: (final text) {
          final category = _getCategory(categories, text);
          currentSelected.value = category;
          return category?.name ?? emptyPlaceholder;
        },
      ),
    );
  }

  ModCategory? _getCategory(
    final List<ModCategory> categories,
    final String? categoryName,
  ) {
    if (categoryName == null || categoryName.isEmpty) {
      return null;
    }
    final lowerCase = categoryName.toLowerCase();
    return categories.firstWhereOrNull(
      (final e) => e.name.toLowerCase().startsWith(lowerCase),
    );
  }

  Future<void> _onConfirm(
    final WidgetRef ref,
    final ModCategory currentSelected,
    final BuildContext context,
    final NahidaliveElement elem,
  ) async {
    final turnstile = await showDialog<String?>(
      context: context,
      builder: (final dCtx) => const TurnstileDialog(),
    );
    if (turnstile == null) {
      return;
    }

    unawaited(
      downloadUrlUseCase(
        repo: ref.read(nahidaRepositoryProvider),
        downloadQueue: ref.read(nahidaDownloadQueueProvider.notifier),
        element: elem,
        category: currentSelected,
        pw: password,
        turnstile: turnstile,
      ),
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
