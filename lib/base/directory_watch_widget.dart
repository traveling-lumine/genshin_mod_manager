import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:logger/logger.dart';

abstract class DirectoryWatchWidget extends StatefulWidget {
  final PathString dirPath;

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
    logger.t('$this bids you a goodbye');
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

abstract class MultiDirectoryWatchWidget extends StatefulWidget {
  final List<PathString> dirPaths;

  const MultiDirectoryWatchWidget({super.key, required this.dirPaths});

  @override
  MDWState createState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($dirPaths)';
  }
}

abstract class MDWState<T extends MultiDirectoryWatchWidget>
    extends State<MultiDirectoryWatchWidget> {
  static final Logger logger = Logger();
  late final List<StreamSubscription<FileSystemEvent>> subscriptions;

  @override
  void initState() {
    super.initState();
    _onUpdate(null);
    logger.t('$this is initialized');
  }

  @override
  void didUpdateWidget(covariant MultiDirectoryWatchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(oldWidget.dirPaths.length == widget.dirPaths.length,
        'Directory count changed');
    var shouldUpdate = false;
    final List<int> updateIndices = [];
    for (var i = 0; i < widget.dirPaths.length; i++) {
      final oldDir = oldWidget.dirPaths[i];
      final newDir = widget.dirPaths[i];
      if (oldDir == newDir) continue;
      logger.t('Directory path changed from $oldDir to $newDir');
      subscriptions[i].cancel();
      updateIndices.add(i);
      shouldUpdate = true;
    }
    if (shouldUpdate) {
      _onUpdate(updateIndices);
    }
  }

  @override
  void dispose() {
    logger.t('$this bids you a goodbye');
    for (final element in subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  void _onUpdate(List<int>? updates) {
    updateFolder(-1);
    if (updates == null) {
      subscriptions = [];
      for (var index = 0; index < widget.dirPaths.length; index++) {
        subscriptions
            .add(widget.dirPaths[index].toDirectory.watch().listen((event) {
          logger.d('$this update: $event');
          if (shouldUpdate(index, event)) {
            logger.d('$this update accepted');
            setState(() => updateFolder(index));
          } else {
            logger.d('$this update rejected');
          }
        }));
      }
    } else {
      for (final index in updates) {
        subscriptions[index] =
            widget.dirPaths[index].toDirectory.watch().listen((event) {
          logger.d('$this update: $event');
          if (shouldUpdate(index, event)) {
            logger.d('$this update accepted');
            setState(() => updateFolder(index));
          } else {
            logger.d('$this update rejected');
          }
        });
      }
    }
  }

  bool shouldUpdate(int index, FileSystemEvent event);

  void updateFolder(int index);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '${super.toString(minLevel: minLevel)}($widget)';
  }
}
