import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../util/display_infobar.dart';
import '../util/show_prompt_dialog.dart';
import 'latest_image.dart';
import 'run_pane.dart';

class ModFlyoutImage extends HookWidget {
  const ModFlyoutImage({
    required this.imagePath,
    super.key,
  });
  final String imagePath;

  @override
  Widget build(final BuildContext context) {
    final flyoutController = useFlyoutController();
    return FlyoutTarget(
      controller: flyoutController,
      child: Builder(
        builder: (final context) => GestureDetector(
          onLongPress: () async => _onImageLongPress(context, imagePath),
          onSecondaryTapUp: (final details) async => _onImageRightClick(
            context,
            details,
            imagePath,
            flyoutController,
          ),
          child: Hero(
            tag: imagePath,
            child: LatestImage(path: imagePath),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imagePath', imagePath));
  }

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
    final FlyoutController flyoutController,
  ) async {
    final userResponse =
        await _showImageFlyout(context, details, flyoutController);
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
    final FlyoutController flyoutController,
  ) async {
    final box = context.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(
      details.localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    return flyoutController.showFlyout<bool?>(
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
