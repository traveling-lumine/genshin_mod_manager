import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService with ChangeNotifier {
  static const Duration sharedPreferencesAwaitTime = Duration(seconds: 5);

  @Deprecated('Use modRootKey, modExecFileKey instead')
  static const String targetDirKey = 'targetDir';

  static const String modRootKey = 'modRoot';
  static const String modExecFileKey = 'modExecFile';

  static const String launcherFileKey = 'launcherDir';
  static const String runTogetherKey = 'runTogether';
  static const String moveOnDragKey = 'moveOnDrag';
  static const String showFolderIconKey = 'showFolderIcon';

  SharedPreferences? _sharedPreferences;

  @Deprecated('Use _modRoot, _modExecFile instead')
  PathString _targetDir = const PathString('.');

  PathString _modRoot = const PathString('.');
  PathString _modExecFile = const PathString('.');
  PathString _launcherFile = const PathString('.');
  bool _runTogether = false;
  bool _moveOnDrag = false;
  bool _showFolderIcon = true;
  late Future<SharedPreferences> _initFuture;

  Future<SharedPreferences> get initFuture => _initFuture;

  @Deprecated('Use modRoot, modExecFile instead')
  PathString get targetDir => _targetDir;

  PathString get modRoot => _modRoot;

  PathString get modExecFile => _modExecFile;

  PathString get launcherFile => _launcherFile;

  bool get showFolderIcon => _showFolderIcon;

  bool get moveOnDrag => _moveOnDrag;

  bool get runTogether => _runTogether;

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

      final tDirRaw = value.getString(targetDirKey);
      _targetDir = tDirRaw == null ? _targetDir : PathString(tDirRaw);

      final mRootRaw = value.getString(modRootKey);
      _modRoot = mRootRaw == null ? _modRoot : PathString(mRootRaw);
      const dotString = const PathString('.');
      if (_modRoot == dotString && _targetDir != dotString) {
        _modRoot = _targetDir.join(const PathString('Mods'));
        _sharedPreferences?.setString(modRootKey, _modRoot.asString);
      }

      final mExecRaw = value.getString(modExecFileKey);
      _modExecFile = mExecRaw == null ? _modExecFile : PathString(mExecRaw);
      if (_modExecFile == dotString && _targetDir != dotString) {
        _modExecFile = _targetDir.join(const PathString('3DMigoto Loader.exe'));
        _sharedPreferences?.setString(modExecFileKey, _modExecFile.asString);
      }

      final lFileRaw = value.getString(launcherFileKey);
      _launcherFile = lFileRaw == null ? _launcherFile : PathString(lFileRaw);

      _runTogether = value.getBool(runTogetherKey) ?? _runTogether;

      _moveOnDrag = value.getBool(moveOnDragKey) ?? _moveOnDrag;

      _showFolderIcon = value.getBool(showFolderIconKey) ?? _showFolderIcon;

      notifyListeners();
      return value;
    });
  }

  set initFuture(Future<SharedPreferences> value) {
    _initFuture = value;
    notifyListeners();
  }

  @Deprecated('Use modRoot, modExecFile instead')
  set targetDir(PathString value) {
    _sharedPreferences?.setString(targetDirKey, value.asString);
    _targetDir = value;
    notifyListeners();
  }

  set modRoot(PathString value) {
    _sharedPreferences?.setString(modRootKey, value.asString);
    _modRoot = value;
    notifyListeners();
  }

  set modExecFile(PathString value) {
    _sharedPreferences?.setString(modExecFileKey, value.asString);
    _modExecFile = value;
    notifyListeners();
  }

  set launcherFile(PathString value) {
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

  @override
  String toString() {
    return 'AppStateService{'
        'modRoot: $modRoot, '
        'modExecFile: $modExecFile, '
        'launcherFile: $launcherFile, '
        'runTogether: $runTogether, '
        'moveOnDrag: $moveOnDrag, '
        'showFolderIcon: $showFolderIcon}';
  }
}
