import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_state/move_on_drag.dart';
import '../../fs_interface/entity/setting_data.dart';
import '../../fs_interface/usecase/folder_drop.dart';
import '../../structure/entity/mod_category.dart';
import '../util/display_infobar.dart';
import 'fade_in.dart';

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
      onDragDone: (final details) =>
          unawaited(_onDragDone(details, context, ref)),
      child: FadeInWidget(
        visible: state.value,
        fadeTarget: _buildDropHint(ref, state),
        child: child,
      ),
    );
  }

  Widget _buildDropHint(
    final WidgetRef ref,
    final ValueNotifier<bool> state,
  ) {
    final context = useContext();
    final moveMethod = switch (ref.watch(moveOnDragProvider)) {
      DragImportType.move => 'move',
      DragImportType.copy => 'copy',
    };
    final typography = FluentTheme.of(context).typography;
    return RichText(
      text: TextSpan(
        text: 'Drop to $moveMethod to',
        style: typography.body,
        children: [
          TextSpan(text: ' ${category.name}', style: typography.bodyStrong),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

  Future<void> _onDragDone(
    final DropDoneDetails details,
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final moveInsteadOfCopy = ref.read(moveOnDragProvider);
    final result = await dragToImportUseCase(
      details.files.map((final e) => e.path),
      category.path,
      moveInsteadOfCopy,
    );
    if (result.errors.isNotEmpty && context.mounted) {
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
          .map((final e) => "'${e.source}' -> '${e.destination}'")
          .join('\n');
      final dragImportType = switch (moveInsteadOfCopy) {
        DragImportType.move => 'moved',
        DragImportType.copy => 'copied',
      };
      if (context.mounted) {
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
}
