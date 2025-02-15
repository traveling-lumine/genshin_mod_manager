import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/entity/entries.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l0/usecase/move_dir.dart';
import '../../filesystem/l1/di/fs_watcher.dart';
import '../../filesystem/l1/di/mods_in_category.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import '../util/display_infobar.dart';
import 'category_drop_target.dart';
import 'fade_in.dart';
import 'latest_image.dart';

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
          icon: _buildIcon(category),
          body: const SizedBox.shrink(),
          infoBadge: Consumer(
            builder: (final context, final ref, final child) {
              final mods = ref.watch(
                modsInCategoryStreamProvider(category).select(
                  (final value) => value.whenOrNull(data: (final data) => data),
                ),
              );
              if (mods == null) {
                return const SizedBox.shrink();
              }
              final totalCount = mods.length;
              if (totalCount == 0) {
                return const SizedBox.shrink();
              }
              final activeCount = mods.where((final e) => e.isEnabled).length;
              final color = switch (activeCount) {
                <= 1 => null,
                <= 2 => Colors.yellow,
                <= 5 => Colors.orange,
                _ => Colors.red,
              };
              return Text(
                '$activeCount/$totalCount',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
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
      moveDirUseCase(
        Directory(details.data.path),
        category.path.pJoin(details.data.path.pBasename),
      );
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

  static Widget _buildIcon(final ModCategory category) => Consumer(
        builder: (final context, final ref, final child) => ref.watch(
          appConfigFacadeProvider
              .select((final value) => value.obtainValue(showFolderIcon)),
        )
            ? _buildImage(category)
            : const Icon(FluentIcons.folder_open),
      );

  static Widget _buildImage(final ModCategory category) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxIconWidth),
        child: Consumer(
          builder: (final context, final ref, final child) {
            final imagePath = ref
                .watch(folderIconPathStreamProvider(category))
                .whenOrNull(data: (final path) => path);
            return AspectRatio(
              aspectRatio: 1,
              child: imagePath == null
                  ? Consumer(
                      builder: (final context, final ref, final child) =>
                          Image.asset(
                        ref.watch(
                          appConfigFacadeProvider.select(
                            (final value) => value.obtainValue(
                              showPaimonAsEmptyIconFolderIcon,
                            ),
                          ),
                        )
                            ? 'images/app_icon.ico'
                            : 'images/idk_icon.png',
                      ),
                    )
                  : LatestImage(path: imagePath),
            );
          },
        ),
      );
}
