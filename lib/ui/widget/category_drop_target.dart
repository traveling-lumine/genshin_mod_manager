import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/data/helper/copy_directory.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final moveMethod = ref.watch(moveOnDragProvider) ? 'move' : 'copy';
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
    final modRoot = category.path;
    final queue = <(Directory, String)>[];
    for (final xFile in details.files) {
      final path = xFile.path;
      if (!FileSystemEntity.isDirectorySync(path)) {
        continue;
      }
      final sourceDir = Directory(path);
      final newPath = modRoot.pJoin(path.pBasename);
      if (FileSystemEntity.isDirectorySync(newPath)) {
        queue.add((sourceDir, newPath));
        continue;
      }

      if (moveInsteadOfCopy) {
        try {
          sourceDir.renameSync(newPath);
        } on FileSystemException catch (e) {
          if (e.osError?.errorCode == 17) {
            // Moving across different drives
            sourceDir
              ..copyToPath(newPath)
              ..deleteSync(recursive: true);
          } else {
            unawaited(
              displayInfoBarInContext(
                context,
                title: const Text('Error moving folder'),
                content: Text('$e'),
                severity: InfoBarSeverity.error,
              ),
            );
          }
        }
      } else {
        sourceDir.copyToPath(newPath);
      }
    }
    if (queue.isEmpty) {
      return;
    }
    final join = queue
        .map(
          (final e) => "'${e.$1.path.pBasename}' -> '${e.$2.pBasename}'",
        )
        .join('\n');
    unawaited(
      displayInfoBarInContext(
        context,
        title: const Text('Folder already exists'),
        content: Text('The following folders already exist'
            ' and were not ${moveInsteadOfCopy ? 'moved' : 'copied'}: \n'
            '$join'),
        severity: InfoBarSeverity.warning,
      ),
    );
  }
}
