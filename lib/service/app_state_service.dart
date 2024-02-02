import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService with ChangeNotifier {
  static const Duration sharedPreferencesAwaitTime = Duration(seconds: 5);

  static const String _targetDirKey = 'targetDir';
  static const String modRootKey = 'modRoot';
  static const String modExecFileKey = 'modExecFile';
  static const String launcherFileKey = 'launcherDir';
  static const String runTogetherKey = 'runTogether';
  static const String moveOnDragKey = 'moveOnDrag';
  static const String showFolderIconKey = 'showFolderIcon';
  static const String showEnabledModsFirstKey = 'showEnabledModsFirst';

  SharedPreferences? _sharedPreferences;

  PathW _modRoot = const PathW('.');
  PathW _modExecFile = const PathW('.');
  PathW _launcherFile = const PathW('.');
  bool _runTogether = false;
  bool _moveOnDrag = false;
  bool _showFolderIcon = true;
  bool _showEnabledModsFirst = false;
  late Future<SharedPreferences> _initFuture;

  Future<SharedPreferences> get initFuture => _initFuture;

  PathW get modRoot => _modRoot;

  PathW get modExecFile => _modExecFile;

  PathW get launcherFile => _launcherFile;

  bool get runTogether => _runTogether;

  bool get moveOnDrag => _moveOnDrag;

  bool get showFolderIcon => _showFolderIcon;

  bool get showEnabledModsFirst => _showEnabledModsFirst;

  AppStateService() {
    init();
  }

  void init() {
    final future = SharedPreferences.getInstance();
    final timeoutFuture = future.timeout(
      sharedPreferencesAwaitTime,
      onTimeout: () {
        throw TimeoutException(
          'Unable to obtain SharedPreference settings',
          sharedPreferencesAwaitTime,
        );
      },
    );
    initFuture = timeoutFuture.then((value) {
      _sharedPreferences = value;

      const dotString = PathW('.');
      final tDirRaw = value.getString(_targetDirKey);
      final targetDir = tDirRaw == null ? dotString : PathW(tDirRaw);

      final mRootRaw = value.getString(modRootKey);
      _modRoot = mRootRaw == null ? _modRoot : PathW(mRootRaw);
      if (_modRoot == dotString && targetDir != dotString) {
        _modRoot = targetDir.join(const PathW('Mods'));
        _sharedPreferences?.setString(modRootKey, _modRoot.asString);
      }

      final mExecRaw = value.getString(modExecFileKey);
      _modExecFile = mExecRaw == null ? _modExecFile : PathW(mExecRaw);
      if (_modExecFile == dotString && targetDir != dotString) {
        _modExecFile = targetDir.join(const PathW('3DMigoto Loader.exe'));
        _sharedPreferences?.setString(modExecFileKey, _modExecFile.asString);
      }

      if (targetDir != dotString) {
        _sharedPreferences?.setString(_targetDirKey, dotString.asString);
      }

      final lFileRaw = value.getString(launcherFileKey);
      _launcherFile = lFileRaw == null ? _launcherFile : PathW(lFileRaw);

      _runTogether = value.getBool(runTogetherKey) ?? _runTogether;

      _moveOnDrag = value.getBool(moveOnDragKey) ?? _moveOnDrag;

      _showFolderIcon = value.getBool(showFolderIconKey) ?? _showFolderIcon;

      _showEnabledModsFirst =
          value.getBool(showEnabledModsFirstKey) ?? _showEnabledModsFirst;

      notifyListeners();
      return value;
    });
  }

  set initFuture(Future<SharedPreferences> value) {
    _initFuture = value;
    notifyListeners();
  }

  set modRoot(PathW value) {
    _sharedPreferences?.setString(modRootKey, value.asString);
    _modRoot = value;
    notifyListeners();
  }

  set modExecFile(PathW value) {
    _sharedPreferences?.setString(modExecFileKey, value.asString);
    _modExecFile = value;
    notifyListeners();
  }

  set launcherFile(PathW value) {
    _sharedPreferences?.setString(launcherFileKey, value.asString);
    _launcherFile = value;
    notifyListeners();
  }

  set runTogether(bool value) {
    _sharedPreferences?.setBool(runTogetherKey, value);
    _runTogether = value;
    notifyListeners();
  }

  set moveOnDrag(bool value) {
    _sharedPreferences?.setBool(moveOnDragKey, value);
    _moveOnDrag = value;
    notifyListeners();
  }

  set showFolderIcon(bool value) {
    _sharedPreferences?.setBool(showFolderIconKey, value);
    _showFolderIcon = value;
    notifyListeners();
  }

  set showEnabledModsFirst(bool value) {
    _sharedPreferences?.setBool(showEnabledModsFirstKey, value);
    _showEnabledModsFirst = value;
    notifyListeners();
  }

  @override
  String toString() {
    return 'AppStateService{'
        'modRoot: $modRoot, '
        'modExecFile: $modExecFile, '
        'launcherFile: $launcherFile, '
        'runTogether: $runTogether, '
        'moveOnDrag: $moveOnDrag, '
        'showFolderIcon: $showFolderIcon}, '
        'showEnabledModsFirst: $showEnabledModsFirst}';
  }
}
