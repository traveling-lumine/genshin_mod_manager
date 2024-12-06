import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_state/folder_icon.dart';
import '../../app_state/use_paimon.dart';
import '../../fs_interface/di/fs_watcher.dart';
import '../../structure/entity/mod.dart';
import '../../structure/entity/mod_category.dart';
import '../../structure/usecase/move_mod.dart';
import '../util/display_infobar.dart';
import 'category_drop_target.dart';
import 'fade_in.dart';

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
          final typography = FluentTheme.of(context).typography;
          final body = typography.body;
          final bodyStrong = typography.bodyStrong;
          return FadeInWidget(
            visible: candidateData.isNotEmpty,
            fadeTarget: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Drop to move\n',
                style: body,
                children: [
                  ...candidateData.map(
                    (final e) => TextSpan(
                      text: '${e!.displayName}\n',
                      style: bodyStrong,
                    ),
                  ),
                  TextSpan(text: 'to ', style: body),
                  TextSpan(text: category.name, style: bodyStrong),
                ],
              ),
            ),
            child: CategoryDropTarget(
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
            ),
          );
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
        builder: (final context, final ref, final child) =>
            ref.watch(folderIconProvider)
                ? _buildImage(name)
                : const Icon(FluentIcons.folder_open),
      );

  static Widget _buildImage(final String name) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxIconWidth),
        child: Consumer(
          builder: (final context, final ref, final child) {
            final imageFile = ref.watch(folderIconPathProvider(name));
            return AspectRatio(
              aspectRatio: 1,
              child: imageFile == null
                  ? Consumer(
                      builder: (final context, final ref, final child) =>
                          Image.asset(
                        ref.watch(paimonIconProvider)
                            ? 'images/app_icon.ico'
                            : 'images/idk_icon.png',
                      ),
                    )
                  : Image.file(File(imageFile), fit: BoxFit.contain),
            );
          },
        ),
      );
}
