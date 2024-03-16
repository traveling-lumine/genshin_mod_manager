import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/helper/copy_directory.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CategoryDropTarget extends StatelessWidget {
  const CategoryDropTarget({
    required this.child,
    required this.category,
    super.key,
  });

  static final Logger logger = Logger();

  final Widget child;
  final ModCategory category;

  @override
  Widget build(final BuildContext context) => DropTarget(
        onDragDone: (final details) => onDragDone(context, details),
        child: child,
      );

  void onDragDone(final BuildContext context, final DropDoneDetails details) {
    final moveInsteadOfCopy = context.read<AppStateService>().moveOnDrag.latest;
    if (moveInsteadOfCopy == null) return;
    final modRoot = category.path;
    final queue = <(Directory, String)>[];
    for (final xFile in details.files) {
      final path = xFile.path;
      if (!FileSystemEntity.isDirectorySync(path)) continue;
      final dir = Directory(path);
      final newPath = modRoot.pJoin(path.pBasename);
      if (FileSystemEntity.isDirectorySync(newPath)) {
        queue.add((dir, newPath));
        continue;
      }

      if (moveInsteadOfCopy) {
        try {
          dir.renameSync(newPath);
          logger.d('Moved $path to $newPath');
        } on FileSystemException catch (e) {
          if (e.osError?.errorCode == 87) {
            displayInfoBarInContext(
              context,
              title: const Text('Incorrect parameter'),
              severity: InfoBarSeverity.error,
            );
          } else {
            dir.copyToPath(newPath);
            dir.deleteSync(recursive: true);
            logger.d('Fallback: copy-deleted $path to $newPath');
          }
        }
      } else {
        dir.copyToPath(newPath);
        logger.d('Copied $path to $newPath');
      }
    }
    final method = moveInsteadOfCopy ? 'moved' : 'copied';
    if (queue.isEmpty) return;

    displayInfoBarInContext(
      context,
      title: const Text('Folder already exists'),
      content:
          Text('The following folders already exist and were not $method: \n'
              '${queue.map(
                    (final e) =>
                        "'${e.$1.path.pBasename}' -> '${e.$2.pBasename}'",
                  ).join('\n')}'),
      severity: InfoBarSeverity.warning,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}
