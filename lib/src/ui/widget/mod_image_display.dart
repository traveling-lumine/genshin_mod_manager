import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../filesystem/di/mod_card.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import 'latest_image.dart';
import 'mod_flyout_image.dart';

class ModImageDisplay extends ConsumerWidget {
  const ModImageDisplay({
    required this.mod,
    super.key,
  });
  final Mod mod;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final preview = ref.watch(modPreviewPathProvider(mod));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: preview.when(
        data: (final data) => data == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.unknown),
                  const SizedBox(height: 4),
                  RepaintBoundary(
                    child: Button(
                      onPressed: () async => _onPaste(context),
                      child: const Text('Paste'),
                    ),
                  ),
                ],
              )
            : _buildImageDesc(context, data),
        loading: () => const Center(child: ProgressRing()),
        error: (final e, final _) => const Text('Error loading preview'),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', mod));
  }

  Widget _buildImageDesc(final BuildContext context, final String imagePath) =>
      Stack(
        children: [
          SizedBox.expand(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.6),
                    BlendMode.darken,
                  ),
                  child: LatestImage(
                    path: imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: ModFlyoutImage(imagePath: imagePath),
          ),
        ],
      );

  Future<void> _onPaste(final BuildContext context) async {
    final Uint8List? image;
    try {
      image = await Pasteboard.image;
    } on PlatformException catch (e) {
      if (context.mounted) {
        unawaited(
          displayInfoBar(
            context,
            builder: (final _, final close) => InfoBar(
              onClose: close,
              severity: InfoBarSeverity.error,
              title: const Text('Image paste failed'),
              content: Text('Failed to paste image: ${e.message}'),
            ),
          ),
        );
      }
      return;
    }
    if (image == null) {
      return;
    }
    final filePath = mod.path.pJoin('preview.png');
    final bytes = await image.pngUint8List;
    await File(filePath).writeAsBytes(bytes);
    if (context.mounted) {
      unawaited(
        displayInfoBar(
          context,
          builder: (final _, final close) => InfoBar(
            title: const Text('Image pasted'),
            content: Text('to ${mod.path}'),
            onClose: close,
          ),
        ),
      );
    }
  }
}
