import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppStateService createAppStateService() {
  return AppStateServiceImpl();
}

class AppStateServiceImpl extends ChangeNotifier implements AppStateService {
  static const Duration _sharedPreferencesAwaitTime = Duration(seconds: 5);

  static const String _targetDirKey = 'targetDir';
  static const String _modRootKey = 'modRoot';
  static const String _modExecFileKey = 'modExecFile';
  static const String _launcherFileKey = 'launcherDir';
  static const String _runTogetherKey = 'runTogether';
  static const String _moveOnDragKey = 'moveOnDrag';
  static const String _showFolderIconKey = 'showFolderIcon';
  static const String _showEnabledModsFirstKey = 'showEnabledModsFirst';
  static const String _presetDatakey = 'presetData';

  SharedPreferences? _sharedPreferences;

  @override
  Future<bool> get successfulLoad => _successfulLoad;
  late Future<bool> _successfulLoad;

  @override
  set successfulLoad(Future<bool> value) {
    _successfulLoad = value;
    notifyListeners();
  }

  @override
  String get modRoot => _modRoot;
  String _modRoot = '.';

  @override
  set modRoot(String value) {
    _sharedPreferences?.setString(_modRootKey, value);
    _modRoot = value;
    notifyListeners();
  }

  @override
  String get modExecFile => _modExecFile;
  String _modExecFile = '.';

  @override
  set modExecFile(String value) {
    _sharedPreferences?.setString(_modExecFileKey, value);
    _modExecFile = value;
    notifyListeners();
  }

  @override
  String get launcherFile => _launcherFile;
  String _launcherFile = '.';

  @override
  set launcherFile(String value) {
    _sharedPreferences?.setString(_launcherFileKey, value);
    _launcherFile = value;
    notifyListeners();
  }

  @override
  bool get runTogether => _runTogether;
  bool _runTogether = false;

  @override
  set runTogether(bool value) {
    _sharedPreferences?.setBool(_runTogetherKey, value);
    _runTogether = value;
    notifyListeners();
  }

  @override
  bool get moveOnDrag => _moveOnDrag;
  bool _moveOnDrag = false;

  @override
  set moveOnDrag(bool value) {
    _sharedPreferences?.setBool(_moveOnDragKey, value);
    _moveOnDrag = value;
    notifyListeners();
  }

  @override
  bool get showFolderIcon => _showFolderIcon;
  bool _showFolderIcon = true;

  @override
  set showFolderIcon(bool value) {
    _sharedPreferences?.setBool(_showFolderIconKey, value);
    _showFolderIcon = value;
    notifyListeners();
  }

  @override
  bool get showEnabledModsFirst => _showEnabledModsFirst;
  bool _showEnabledModsFirst = false;

  @override
  set showEnabledModsFirst(bool value) {
    _sharedPreferences?.setBool(_showEnabledModsFirstKey, value);
    _showEnabledModsFirst = value;
    notifyListeners();
  }

  @override
  String get presetData => _presetData;
  String _presetData = '123';

  @override
  set presetData(String value) {
    _sharedPreferences?.setString(_presetDatakey, value);
    _presetData = value;
    notifyListeners();
  }

  AppStateServiceImpl() {
    init();
  }

  @override
  void init() {
    final future = SharedPreferences.getInstance();
    final timeoutFuture = future.timeout(
      _sharedPreferencesAwaitTime,
      onTimeout: () {
        throw TimeoutException(
          'Unable to obtain SharedPreference settings',
          _sharedPreferencesAwaitTime,
        );
      },
    );
    successfulLoad = timeoutFuture.then((value) {
      _sharedPreferences = value;

      const dotString = '.';
      final tDirRaw = value.getString(_targetDirKey);
      final targetDir = tDirRaw ?? dotString;

      final mRootRaw = value.getString(_modRootKey);
      _modRoot = mRootRaw ?? _modRoot;
      if (_modRoot == dotString && targetDir != dotString) {
        _modRoot = targetDir.pJoin('Mods');
        _sharedPreferences?.setString(_modRootKey, _modRoot);
      }

      final mExecRaw = value.getString(_modExecFileKey);
      _modExecFile = mExecRaw ?? _modExecFile;
      if (_modExecFile == dotString && targetDir != dotString) {
        _modExecFile = targetDir.pJoin('3DMigoto Loader.exe');
        _sharedPreferences?.setString(_modExecFileKey, _modExecFile);
      }

      if (targetDir != dotString) {
        _sharedPreferences?.setString(_targetDirKey, dotString);
      }

      final lFileRaw = value.getString(_launcherFileKey);
      _launcherFile = lFileRaw ?? _launcherFile;

      _runTogether = value.getBool(_runTogetherKey) ?? _runTogether;

      _moveOnDrag = value.getBool(_moveOnDragKey) ?? _moveOnDrag;

      _showFolderIcon = value.getBool(_showFolderIconKey) ?? _showFolderIcon;

      _showEnabledModsFirst =
          value.getBool(_showEnabledModsFirstKey) ?? _showEnabledModsFirst;

      _presetData = value.getString(_presetDatakey) ?? _presetData;

      notifyListeners();
      return true;
    });
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
