import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/copy_directory.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CategoryDropTarget extends StatelessWidget {
  static final Logger logger = Logger();

  final Widget child;
  final ModCategory category;

  const CategoryDropTarget({
    super.key,
    required this.child,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) => onDragDone(context, details),
      child: child,
    );
  }

  void onDragDone(BuildContext context, DropDoneDetails details) {
    final moveInsteadOfCopy = context.read<AppStateService>().moveOnDrag.latest;
    final modRoot = category.path;
    final List<(Directory, String)> queue = [];
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
        } on FileSystemException {
          dir.copyToPath(newPath);
          dir.deleteSync(recursive: true);
          logger.d('Fallback: copy-deleted $path to $newPath');
        }
      } else {
        dir.copyToPath(newPath);
        logger.d('Copied $path to $newPath');
      }
    }
    final method = moveInsteadOfCopy ? 'moved' : 'copied';
    if (queue.isEmpty) return;

    displayInfoBar(
      context,
      builder: (context, close) {
        final joined = queue.map((e) {
          final (dir, pw) = e;
          return "'${dir.path.pBasename}' -> '${pw.pBasename}'";
        }).join('\n');
        return InfoBar(
          title: const Text('Folder already exists'),
          content: Text(
              'The following folders already exist and were not $method: \n$joined'),
          severity: InfoBarSeverity.warning,
          onClose: close,
        );
      },
    );
  }
}
