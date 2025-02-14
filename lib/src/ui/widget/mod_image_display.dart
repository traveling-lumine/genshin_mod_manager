import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../filesystem/di/mod_card.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import '../constants.dart';
import '../util/display_infobar.dart';
import '../util/show_prompt_dialog.dart';
import 'mod_preview_image.dart';

class ModImageDisplay extends ConsumerWidget {
  ModImageDisplay({
    required this.mod,
    super.key,
  });
  final Mod mod;
  final _contextController = FlyoutController();
  final _contextAttachKey = GlobalKey();

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
                  child: ModPreviewImage(
                    path: imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onLongPress: () async => _onImageLongPress(context, imagePath),
              onSecondaryTapUp: (final details) async =>
                  _onImageRightClick(context, details, imagePath),
              child: FlyoutTarget(
                controller: _contextController,
                key: _contextAttachKey,
                child: Hero(
                  tag: imagePath,
                  child: ModPreviewImage(path: imagePath),
                ),
              ),
            ),
          ),
        ],
      );
  Future<void> _onImageFlyoutDeletePressed(
    final BuildContext context,
    final BuildContext fCtx,
  ) async {
    final userResponse = await _showImageDeleteConfirmDialog(context);
    if (fCtx.mounted) {
      Navigator.of(fCtx).pop(userResponse);
    }
  }

  Future<void> _onImageLongPress(
    final BuildContext context,
    final String image,
  ) async =>
      context.pushNamed(
        RouteNames.categoryHero.name,
        pathParameters: {RouteParams.categoryHeroTag.name: image},
      );

  Future<void> _onImageRightClick(
    final BuildContext context,
    final TapUpDetails details,
    final String imagePath,
  ) async {
    final userResponse = await _showImageFlyout(context, details);
    if (userResponse != true) {
      return;
    }
    await File(imagePath).delete();
    if (context.mounted) {
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Preview deleted'),
          content: Text('Preview deleted from $imagePath'),
          severity: InfoBarSeverity.warning,
        ),
      );
    }
  }

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

  Future<bool> _showImageDeleteConfirmDialog(final BuildContext context) =>
      showPromptDialog(
        context: context,
        title: 'Delete preview image?',
        content:
            const Text('Are you sure you want to delete the preview image?'),
        confirmButtonLabel: 'Delete',
        redButton: true,
      );

  Future<bool?> _showImageFlyout(
    final BuildContext context,
    final TapUpDetails details,
  ) async {
    final targetContext = _contextAttachKey.currentContext;
    if (targetContext == null) {
      return null;
    }
    final box = targetContext.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(
      details.localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    return _contextController.showFlyout<bool?>(
      position: position,
      builder: (final fCtx) => FlyoutContent(
        child: IntrinsicWidth(
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.clip,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () async =>
                    _onImageFlyoutDeletePressed(context, fCtx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
