import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/structure/entity/mod_category.dart';
import '../../di/app_state/folder_icon.dart';
import '../../di/app_state/use_paimon.dart';
import '../../di/fs_watcher.dart';
import 'category_drop_target.dart';
import 'custom_image.dart';

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
          icon: _getIcon(category.name),
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
      CategoryDropTarget(
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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

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
      image = TimeAwareFileImage(path: imageFile);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxIconWidth),
      child: AspectRatio(
        aspectRatio: 1,
        child: image,
      ),
    );
  }

  static Widget _getIcon(final String name) => Consumer(
        builder: (final context, final ref, final child) {
          final filePath = ref.watch(folderIconPathProvider(name));
          return ref.watch(folderIconProvider)
              ? _buildImage(filePath)
              : const Icon(FluentIcons.folder_open);
        },
      );
}
