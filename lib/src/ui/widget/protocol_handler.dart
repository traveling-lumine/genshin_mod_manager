import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/nahida/domain/entity/nahida_element.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/exe_arg.dart';
import '../../di/nahida_download_queue.dart';
import '../../di/nahida_store.dart';
import '../../di/structure/categories.dart';
import '../util/display_infobar.dart';

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
) async {
  final nahida = ref.read(nahidaApiProvider);
  final uuid = _convertUuid(rawUuid);
  final elem = await nahida.fetchNahidaliveElement(uuid);
  return elem;
}

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

  Future<void> _onUriInput(
    final BuildContext context,
    final WidgetRef ref,
    final String url,
  ) async {
    final parsed = Uri.parse(url);
    final rawUuid = parsed.queryParameters['uuid'];
    if (rawUuid == null) {
      return _showInvalidUriInfoBar(context);
    }

    final password = parsed.queryParameters['pw'];
    final categoryName = GoRouterState.of(context).pathParameters['category'];
    final category = ref
        .read(categoriesProvider)
        .firstWhereOrNull((final e) => e.name == categoryName);

    if (category != null) {
      final NahidaliveElement elem;
      try {
        elem = await _getElement(ref, rawUuid);
      } on Exception catch (e) {
        if (context.mounted) {
          _showDownloadFailedInfoBar(context, e);
        }
        return;
      }
      unawaited(
        ref
            .read(
              nahidaDownloadQueueProvider.notifier,
            )
            .addDownload(element: elem, category: category, pw: password),
      );
      return;
    }

    _showProtocolConfirmDialog(context, url, rawUuid, category, password);
  }

  void _showDownloadFailedInfoBar(
    final BuildContext context,
    final Exception e,
  ) =>
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Download failed'),
          content: Text('$e'),
          severity: InfoBarSeverity.error,
        ),
      );

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

  Future<void> _showInvalidUriInfoBar(final BuildContext context) =>
      displayInfoBarInContext(
        context,
        title: const Text('Invalid URL'),
        content: const Text('The URL does not contain a UUID.'),
        severity: InfoBarSeverity.error,
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
      content: _buildContent(currentSelected, categories),
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
        DiagnosticsProperty<ModCategory?>(
          'initialCategory',
          initialCategory,
        ),
      )
      ..add(StringProperty('password', password));
  }

  Widget _buildContent(
    final ValueNotifier<ModCategory?> currentSelected,
    final List<ModCategory> categories,
  ) =>
      IntrinsicHeight(
        child: ComboboxFormField<ModCategory>(
          value: currentSelected.value,
          items: categories
              .map(
                (final e) => ComboBoxItem(value: e, child: Text(e.name)),
              )
              .toList(),
          onChanged: (final value) {
            currentSelected.value = value;
          },
          validator: (final value) =>
              value == null ? 'Please select a category' : null,
          autovalidateMode: AutovalidateMode.always,
        ),
      );

  Future<void> _onConfirm(
    final WidgetRef ref,
    final ModCategory currentSelected,
    final BuildContext context,
    final NahidaliveElement elem,
  ) async {
    unawaited(
      ref
          .read(
            nahidaDownloadQueueProvider.notifier,
          )
          .addDownload(element: elem, category: currentSelected, pw: password),
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
