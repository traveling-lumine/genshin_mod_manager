import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class ModCardViewModel implements BaseViewModel {
  String? get configPath;

  String? get previewPath;

  List<String>? get iniPaths;
}

ModCardViewModel createModCardViewModel({
  required final FSEPathsWatcher fsePathsWatcher,
}) =>
    _ModCardViewModelImpl(fsePathsWatcher: fsePathsWatcher);

class _ModCardViewModelImpl extends ChangeNotifier implements ModCardViewModel {
  _ModCardViewModelImpl({
    required final FSEPathsWatcher fsePathsWatcher,
  }) {
    fsePathsWatcher.paths.stream.listen((final event) {
      _paths = event;
      configPath = _paths?.firstWhereOrNull(
        (final file) => file.pBasename.pEquals(kAkashaConfigFilename),
      );
      previewPath = findPreviewFileInString(event) ?? '';
      iniPaths = getActiveIniPaths(event);
      notifyListeners();
    });
  }

  List<String>? _paths;

  @override
  String? configPath;

  @override
  String? previewPath;

  @override
  List<String>? iniPaths;
}
