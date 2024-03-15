import 'package:genshin_mod_manager/domain/entity/fs_event.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/repo/disposable.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';

abstract interface class RecursiveFileSystemWatcher implements Disposable {
  LatestStream<FSEvent> get event;

  void cut();

  void uncut();

  void forceUpdate();
}

abstract interface class FSEPathsWatcher implements Disposable {
  LatestStream<List<String>> get paths;
}

abstract interface class ModsWatcher implements Disposable {
  LatestStream<List<Mod>> get mods;
}

abstract interface class FileWatcher implements Disposable {
  LatestStream<int> get updateCode;
}
