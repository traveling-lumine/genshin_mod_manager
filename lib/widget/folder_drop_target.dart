import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/copy_directory.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class FolderDropTarget extends StatelessWidget {
  static final Logger logger = Logger();

  final Widget child;
  final PathString dirPath;

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
    final moveInsteadOfCopy = context.read<AppState>().moveOnDrag;
    for (final xFile in details.files) {
      final path = PathString(xFile.path);
      if (!path.isDirectorySync) continue;
      logger.d('Dragged $path');
      final dir = path.toDirectory;
      final newPath = dirPath.join(path.basename);
      try {
        if (moveInsteadOfCopy) {
          dir.renameSyncPath(newPath);
          logger.d('Moved $path to $newPath');
        } else {
          dir.copyToPath(newPath);
          logger.d('Copied $path to $newPath');
        }
      } on PathExistsException {
        displayInfoBar(
          context,
          builder: (context, close) {
            return InfoBar(
              title: const Text('Folder already exists'),
              severity: InfoBarSeverity.warning,
              onClose: close,
            );
          },
        );
      }
    }
  }
}
