import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/fs_interface/domain/entity/setting_data.dart';
import '../../backend/fs_interface/domain/usecase/folder_drop.dart';
import '../../backend/storage/di/app_state.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../util/display_infobar.dart';

/// A widget that acts as a drop target for files and directories.
class CategoryDropTarget extends HookConsumerWidget {
  /// Creates a [CategoryDropTarget].
  const CategoryDropTarget({
    required this.child,
    required this.category,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// The category to drop the files into.
  final ModCategory category;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final state = useState(false);
    return DropTarget(
      onDragEntered: (final details) {
        state.value = true;
      },
      onDragExited: (final details) {
        state.value = false;
      },
      onDragDone: (final details) => _onDragDone(details, context, ref),
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: _buildDropHint(ref, state),
          ),
        ],
      ),
    );
  }

  AnimatedOpacity _buildDropHint(
    final WidgetRef ref,
    final ValueNotifier<bool> state,
  ) {
    final context = useContext();
    final moveMethod = switch (ref.watch(moveOnDragProvider)) {
      DragImportType.move => 'move',
      DragImportType.copy => 'copy',
    };
    final text = RichText(
      text: TextSpan(
        text: 'Drop to $moveMethod to',
        style: FluentTheme.of(context).typography.body,
        children: [
          TextSpan(
            text: ' ${category.name}',
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ],
      ),
    );
    return AnimatedOpacity(
      opacity: state.value ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: Offstage(
        offstage: !state.value,
        child: Acrylic(
          blurAmount: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: text,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

  void _onDragDone(
    final DropDoneDetails details,
    final BuildContext context,
    final WidgetRef ref,
  ) {
    final moveInsteadOfCopy = ref.read(moveOnDragProvider);
    final result = dragToImportUseCase(
      details.files.map((final e) => e.path),
      category.path,
      moveInsteadOfCopy,
    );
    if (result.errors.isNotEmpty) {
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Error moving folder'),
          content: Text(result.errors.map((final e) => e.message).join('\n')),
          severity: InfoBarSeverity.error,
        ),
      );
    }
    if (result.exists.isNotEmpty) {
      final join = result.exists
          .map(
            (final e) => "'${e.source}' -> '${e.destination}'",
          )
          .join('\n');
      final dragImportType = switch (moveInsteadOfCopy) {
        DragImportType.move => 'moved',
        DragImportType.copy => 'copied',
      };
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Folder already exists'),
          content: Text('The following folders already exist'
              ' and were not $dragImportType: \n'
              '$join'),
          severity: InfoBarSeverity.warning,
        ),
      );
    }
  }
}
