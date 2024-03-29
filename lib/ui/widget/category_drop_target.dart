import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/helper/copy_directory.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CategoryDropTarget extends ConsumerWidget {
  const CategoryDropTarget({
    required this.child,
    required this.category,
    super.key,
  });

  final Widget child;
  final ModCategory category;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => DropTarget(
        onDragDone: (final details) => _onDragDone(details, context, ref),
        child: child,
      );

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
    final moveInsteadOfCopy = ref.read(
      appStateNotifierProvider.select((final value) => value.moveOnDrag),
    );
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
          if (e.osError?.errorCode == 87) {
            unawaited(
              displayInfoBarInContext(
                context,
                title: const Text('Incorrect parameter'),
                severity: InfoBarSeverity.error,
              ),
            );
          } else {
            sourceDir
              ..copyToPath(newPath)
              ..deleteSync(recursive: true);
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
