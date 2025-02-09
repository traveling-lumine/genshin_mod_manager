import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import '../../mod_writer/l1/mod_writer.dart';
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
            :final category,
            :final data,
            :final element
          ):
          unawaited(
            _showNahidaZipExtractionErrorInfoBar(
              context,
              element,
              category,
              data,
            ),
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

  Future<void> _showNahidaZipExtractionErrorInfoBar(
    final BuildContext context,
    final NahidaliveElement element,
    final ModCategory category,
    final Uint8List data,
  ) async {
    var writeSuccess = false;
    Exception? exception;
    final fileName = sanitizeString('${element.title}.zip');
    try {
      await File(category.path.pJoin(fileName)).writeAsBytes(data);
      writeSuccess = true;
    } on Exception catch (e) {
      writeSuccess = false;
      exception = e;
    }
    if (context.mounted) {
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
}
