import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/copy_directory.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class FolderDropTarget extends StatelessWidget {
  static final Logger logger = Logger();

  final Widget child;
  final PathW dirPath;

  const FolderDropTarget({
    super.key,
    required this.child,
    required this.dirPath,
  });

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        _dropFinishHandler(context, details);
      },
      child: child,
    );
  }

  void _dropFinishHandler(BuildContext context, DropDoneDetails details) {
    final moveInsteadOfCopy = context.read<AppStateService>().moveOnDrag;
    final List<(Directory, PathW)> queue = [];
    for (final xFile in details.files) {
      final path = PathW(xFile.path);
      if (!path.isDirectorySync) continue;
      final dir = path.toDirectory;
      final newPath = dirPath.join(path.basename);
      if (newPath.isDirectorySync) {
        queue.add((dir, newPath));
        continue;
      }

      if (moveInsteadOfCopy) {
        try {
          dir.renameSyncPath(newPath);
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
          return "'${dir.pathW.basename}' -> '${pw.basename.asString}'";
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
