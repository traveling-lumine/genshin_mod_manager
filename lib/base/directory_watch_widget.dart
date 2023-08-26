import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';

abstract class DirectoryWatchWidget extends StatefulWidget {
  final String dirPath;

  Directory get dir => Directory(dirPath);

  const DirectoryWatchWidget({super.key, required this.dirPath});

  @override
  DWState createState();
}

abstract class DWState<T extends DirectoryWatchWidget>
    extends State<DirectoryWatchWidget> {
  static final Logger logger = Logger();
  StreamSubscription<FileSystemEvent>? subscription;

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
    subscription?.cancel();
    _onUpdate();
  }

  @override
  void dispose() {
    logger.t('$DirectoryWatchWidget bids you a goodbye');
    subscription?.cancel();
    super.dispose();
  }

  void _onUpdate() {
    updateFolder();
    subscription = widget.dir.watch().listen((event) {
      if (shouldUpdate(event)) {
        logger.d('DWW update: $event');
        setState(() => updateFolder());
      }
    });
  }

  bool shouldUpdate(FileSystemEvent event);

  void updateFolder();
}
