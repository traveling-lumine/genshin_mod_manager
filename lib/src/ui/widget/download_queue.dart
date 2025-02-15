import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../nahida/l0/di/nahida_download_queue.dart';
import '../../nahida/l0/entity/download_state.dart';
import '../../nahida/l0/entity/nahida_element.dart';
import '../util/display_infobar.dart';

class DownloadQueue extends ConsumerWidget {
  const DownloadQueue({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(nahidaDownloadQueueProvider, (final previous, final next) {
      if (!next.hasValue) {
        return;
      }
      switch (next.requireValue) {
        case NahidaDownloadStateCompleted(:final element):
          _showNahidaDownloadCompleteInfoBar(context, element);
        case NahidaDownloadStateWrongPassword(:final wrongPw):
          _showNahidaWrongPasswdDialog(context, wrongPw);
        case NahidaDownloadStateModZipExtractionException(
            :final writeSuccess,
            :final fileName,
            :final exception
          ):
          _showNahidaZipExtractionErrorInfoBar(
            context,
            writeSuccess,
            fileName,
            exception,
          );
      }
    });
    return child;
  }

  void _showNahidaDownloadCompleteInfoBar(
    final BuildContext context,
    final NahidaliveElement element,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: Text('Downloaded ${element.title}'),
        severity: InfoBarSeverity.success,
      ),
    );
  }

  void _showNahidaWrongPasswdDialog(
    final BuildContext context,
    final String? wrongPw,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Wrong password'),
        severity: InfoBarSeverity.error,
      ),
    );
  }

  void _showNahidaZipExtractionErrorInfoBar(
    final BuildContext context,
    final bool writeSuccess,
    final String? fileName,
    final Exception? exception,
  ) {
    final contentString = switch (writeSuccess) {
      true => 'Failed to extract archive. '
          'Instead, the archive was saved as $fileName.',
      false => 'Failed to extract archive. '
          'During an attempt to save the archive, '
          'an exception has occurred: $exception',
    };
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Download failed'),
        content: Text(contentString),
        severity: InfoBarSeverity.error,
        duration: const Duration(seconds: 30),
      ),
    );
  }
}
