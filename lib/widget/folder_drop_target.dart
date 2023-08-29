import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/copy_directory.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../provider/app_state.dart';

class FolderDropTarget extends StatelessWidget {
  static final Logger logger = Logger();

  final Widget child;
  final String dirPath;

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
      final path = xFile.path;
      if (!FileSystemEntity.isDirectorySync(path)) continue;
      logger.d('Dragged $path');
      final dir = Directory(path);
      final newPath = p.join(dirPath, p.basename(path));
      try {
        if (moveInsteadOfCopy) {
          dir.renameSync(newPath);
          logger.d('Moved $path to $newPath');
        } else {
          dir.copyTo(newPath);
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
