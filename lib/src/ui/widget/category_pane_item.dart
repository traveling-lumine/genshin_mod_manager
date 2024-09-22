import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/structure/entity/mod.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../backend/structure/usecase/move_mod.dart';
import '../../di/app_state/folder_icon.dart';
import '../../di/app_state/use_paimon.dart';
import '../../di/fs_watcher.dart';
import '../util/display_infobar.dart';
import 'category_drop_target.dart';
import 'mod_preview_image.dart';

class FolderPaneItem extends PaneItem {
  FolderPaneItem({
    required this.category,
    required super.key,
    super.onTap,
  }) : super(
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _buildIcon(category.name),
          body: const SizedBox.shrink(),
        );
  static const maxIconWidth = 80.0;
  ModCategory category;

  @override
  Widget build(
    final BuildContext context,
    final bool selected,
    final VoidCallback? onPressed, {
    final PaneDisplayMode? displayMode,
    final bool showTextOnTop = true,
    final int? itemIndex,
    final bool? autofocus,
  }) =>
      DragTarget<Mod>(
        onAcceptWithDetails: (final details) =>
            _onModDragAccept(context, details),
        builder: (final context, final candidateData, final rejectedData) {
          final content = CategoryDropTarget(
            category: category,
            child: super.build(
              context,
              selected,
              onPressed,
              displayMode: displayMode,
              showTextOnTop: showTextOnTop,
              itemIndex: itemIndex,
              autofocus: autofocus,
            ),
          );
          if (candidateData.isNotEmpty) {
            final typography = FluentTheme.of(context).typography;
            final body = typography.body;
            final bodyStrong = typography.bodyStrong;
            return Stack(
              children: [
                content,
                Positioned.fill(
                  child: Acrylic(
                    blurAmount: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Drop to move\n',
                            style: body,
                            children: [
                              TextSpan(
                                text: '${candidateData.first?.displayName}\n',
                                style: bodyStrong,
                              ),
                              TextSpan(
                                text: 'to ',
                                style: body,
                              ),
                              TextSpan(
                                text: category.name,
                                style: bodyStrong,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return content;
        },
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

  void _onModDragAccept(
    final BuildContext context,
    final DragTargetDetails<Mod> details,
  ) {
    try {
      moveModUseCase(category: category, mod: details.data);
    } on Exception catch (e) {
      _showMoveErrorInfoBar(context, e);
      return;
    }
    _showMoveDoneInfoBar(context, details);
  }

  void _showMoveDoneInfoBar(
    final BuildContext context,
    final DragTargetDetails<Mod> details,
  ) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Moved!'),
        content: Text('Moved ${details.data.displayName} to ${category.name}'),
        severity: InfoBarSeverity.success,
      ),
    );
  }

  void _showMoveErrorInfoBar(final BuildContext context, final Exception e) {
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Error'),
        content: Text(e.toString()),
        severity: InfoBarSeverity.error,
      ),
    );
  }

  static Widget _buildIcon(final String name) => Consumer(
        builder: (final context, final ref, final child) {
          final filePath = ref.watch(folderIconPathProvider(name));
          return ref.watch(folderIconProvider)
              ? _buildImage(filePath)
              : const Icon(FluentIcons.folder_open);
        },
      );

  static Widget _buildImage(final String? imageFile) {
    final Widget image;
    if (imageFile == null) {
      image = Consumer(
        builder: (final context, final ref, final child) {
          final usePaimon = ref.watch(paimonIconProvider);
          return usePaimon
              ? Image.asset('images/app_icon.ico')
              : Image.asset('images/idk_icon.png');
        },
      );
    } else {
      image = ModPreviewImage(path: imageFile, bypass: true);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxIconWidth),
      child: AspectRatio(aspectRatio: 1, child: image),
    );
  }
}
