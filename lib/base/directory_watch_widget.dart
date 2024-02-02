import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:logger/logger.dart';

abstract class DirectoryWatchWidget extends StatefulWidget {
  final PathW dirPath;

  const DirectoryWatchWidget({super.key, required this.dirPath});

  @override
  DWState createState();
}

abstract class DWState<T extends DirectoryWatchWidget>
    extends State<DirectoryWatchWidget> {
  static final Logger logger = Logger();
  late StreamSubscription<FileSystemEvent> subscription;

  @override
  void initState() {
    super.initState();
    _onUpdate();
  }

  @override
  void didUpdateWidget(covariant DirectoryWatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldDir = oldWidget.dirPath;
    final newDir = widget.dirPath;
    if (oldDir == newDir) return;
    logger.t('Directory path changed from $oldDir to $newDir');
    subscription.cancel();
    _onUpdate();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _onUpdate() {
    updateFolder();
    subscription = widget.dirPath.toDirectory.watch().listen((event) {
      logger.d('$this update: $event');
      if (shouldUpdate(event)) {
        logger.d('$this update accepted');
        setState(() => updateFolder());
      } else {
        logger.d('$this update rejected');
      }
    });
  }

  bool shouldUpdate(FileSystemEvent event);

  void updateFolder();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($widget)';
  }
}
