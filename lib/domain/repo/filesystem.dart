import 'dart:io';

import 'package:flutter/foundation.dart';

abstract interface class FSWatchService {
  Stream<FileSystemEvent?> get event;

  void dispose();
}

abstract interface class RecursiveFSWatchService extends FSWatchService {
  void cut();

  void uncut();

  void forceUpdate();
}

abstract interface class RelayFSEWatchService<T extends FileSystemEntity>
    extends ChangeNotifier {
  List<T> get entities;
}
