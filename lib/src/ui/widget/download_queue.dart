import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../fs_interface/helper/path_op_string.dart';
import '../../mod_writer/data/mod_writer.dart';
import '../../nahida/di/nahida_download_queue.dart';
import '../../nahida/domain/entity/download_state.dart';
import '../../nahida/domain/entity/nahida_element.dart';
import '../../structure/entity/mod_category.dart';
import '../util/display_infobar.dart';

class DownloadQueue extends ConsumerStatefulWidget {
  const DownloadQueue({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<DownloadQueue> createState() => _DownloadQueueState();
}

class _DownloadQueueState extends ConsumerState<DownloadQueue> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(final BuildContext context) {
    ref.listen(nahidaDownloadQueueProvider, (final previous, final next) {
      if (!next.hasValue) {
        return;
      }
      switch (next.requireValue) {
        case NahidaDownloadStateCompleted(:final element):
          _showNahidaDownloadCompleteInfoBar(context, element);
        case NahidaDownloadStateHttpException(:final exception):
          _showNahidaApiErrorInfoBar(context, exception);
        case NahidaDownloadStateWrongPassword(:final completer, :final wrongPw):
          unawaited(_showNahidaWrongPasswdDialog(context, completer, wrongPw));
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
    return widget.child;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _showNahidaApiErrorInfoBar(
    final BuildContext context,
    final HttpException exception,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Download failed'),
        content: Text('${exception.uri}'),
        severity: InfoBarSeverity.error,
      ),
    );
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

  Future<void> _showNahidaWrongPasswdDialog(
    final BuildContext context,
    final Completer<String?> completer,
    final String? wrongPw,
  ) async {
    final userResponse = await showDialog<String?>(
      context: context,
      builder: (final dialogContext) => ContentDialog(
        title: const Text('Enter password'),
        content: IntrinsicHeight(
          child: TextFormBox(
            autovalidateMode: AutovalidateMode.always,
            autofocus: true,
            controller: _textEditingController,
            placeholder: 'Password',
            onFieldSubmitted: (final value) =>
                Navigator.of(dialogContext).pop(_textEditingController.text),
            validator: (final value) {
              if (wrongPw == null || value == null) {
                return null;
              }
              if (value == wrongPw) {
                return 'Wrong password';
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
            onPressed: () =>
                Navigator.of(dialogContext).pop(_textEditingController.text),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    completer.complete(userResponse);
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
