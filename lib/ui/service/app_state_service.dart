import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
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
  static const String presetDatakey = 'presetData';

  SharedPreferences? _sharedPreferences;

  String _modRoot = '.';
  String _modExecFile = '.';
  String _launcherFile = '.';
  bool _runTogether = false;
  bool _moveOnDrag = false;
  bool _showFolderIcon = true;
  bool _showEnabledModsFirst = false;
  String _presetData = '123';
  late Future<SharedPreferences> _initFuture;

  Future<SharedPreferences> get initFuture => _initFuture;

  String get modRoot => _modRoot;

  String get modExecFile => _modExecFile;

  String get launcherFile => _launcherFile;

  bool get runTogether => _runTogether;

  bool get moveOnDrag => _moveOnDrag;

  bool get showFolderIcon => _showFolderIcon;

  bool get showEnabledModsFirst => _showEnabledModsFirst;

  String get presetData => _presetData;

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

      const dotString = '.';
      final tDirRaw = value.getString(_targetDirKey);
      final targetDir = tDirRaw ?? dotString;

      final mRootRaw = value.getString(modRootKey);
      _modRoot = mRootRaw ?? _modRoot;
      if (_modRoot == dotString && targetDir != dotString) {
        _modRoot = targetDir.pJoin('Mods');
        _sharedPreferences?.setString(modRootKey, _modRoot);
      }

      final mExecRaw = value.getString(modExecFileKey);
      _modExecFile = mExecRaw ?? _modExecFile;
      if (_modExecFile == dotString && targetDir != dotString) {
        _modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
        _sharedPreferences?.setString(modExecFileKey, _modExecFile);
      }

      if (targetDir != dotString) {
        _sharedPreferences?.setString(_targetDirKey, dotString);
      }

      final lFileRaw = value.getString(launcherFileKey);
      _launcherFile = lFileRaw ?? _launcherFile;

      _runTogether = value.getBool(runTogetherKey) ?? _runTogether;

      _moveOnDrag = value.getBool(moveOnDragKey) ?? _moveOnDrag;

      _showFolderIcon = value.getBool(showFolderIconKey) ?? _showFolderIcon;

      _showEnabledModsFirst =
          value.getBool(showEnabledModsFirstKey) ?? _showEnabledModsFirst;

      _presetData = value.getString(presetDatakey) ?? _presetData;

      notifyListeners();
      return value;
    });
  }

  set initFuture(Future<SharedPreferences> value) {
    _initFuture = value;
    notifyListeners();
  }

  set modRoot(String value) {
    _sharedPreferences?.setString(modRootKey, value);
    _modRoot = value;
    notifyListeners();
  }

  set modExecFile(String value) {
    _sharedPreferences?.setString(modExecFileKey, value);
    _modExecFile = value;
    notifyListeners();
  }

  set launcherFile(String value) {
    _sharedPreferences?.setString(launcherFileKey, value);
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

  set presetData(String value) {
    _sharedPreferences?.setString(presetDatakey, value);
    _presetData = value;
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
        'showFolderIcon: $showFolderIcon, '
        'showEnabledModsFirst: $showEnabledModsFirst, '
        'presetData: $presetData}';
  }
}
