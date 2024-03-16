import 'dart:async';

import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/mapper/latest_stream.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a new [AppStateService] instance.
AppStateService createAppStateService() => _AppStateServiceImpl();

class _AppStateServiceImpl implements AppStateService {
  _AppStateServiceImpl() {
    reload();
  }

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

  set successfulLoad(final Future<bool> value) {
    _successfulLoad = value;
  }

  @override
  LatestStream<String> get modRoot => vS2LS(_modRoot);
  final BehaviorSubject<String> _modRoot = BehaviorSubject.seeded('.');

  @override
  void setModRoot(final String path) {
    unawaited(_sharedPreferences?.setString(_modRootKey, path));
    _modRoot.add(path);
  }

  @override
  LatestStream<String> get modExecFile => vS2LS(_modExecFile);
  final BehaviorSubject<String> _modExecFile = BehaviorSubject.seeded('.');

  @override
  void setModExecFile(final String path) {
    unawaited(_sharedPreferences?.setString(_modExecFileKey, path));
    _modExecFile.add(path);
  }

  @override
  LatestStream<String> get launcherFile => vS2LS(_launcherFile);
  final BehaviorSubject<String> _launcherFile = BehaviorSubject.seeded('.');

  @override
  void setLauncherFile(final String path) {
    unawaited(_sharedPreferences?.setString(_launcherFileKey, path));
    _launcherFile.add(path);
  }

  @override
  LatestStream<bool> get runTogether => vS2LS(_runTogether);
  final BehaviorSubject<bool> _runTogether = BehaviorSubject.seeded(false);

  @override
  void setRunTogether(final bool value) {
    unawaited(_sharedPreferences?.setBool(_runTogetherKey, value));
    _runTogether.add(value);
  }

  @override
  LatestStream<bool> get moveOnDrag => vS2LS(_moveOnDrag);
  final BehaviorSubject<bool> _moveOnDrag = BehaviorSubject.seeded(false);

  @override
  void setMoveOnDrag(final bool value) {
    unawaited(_sharedPreferences?.setBool(_moveOnDragKey, value));
    _moveOnDrag.add(value);
  }

  @override
  LatestStream<bool> get showFolderIcon => vS2LS(_showFolderIcon);
  final BehaviorSubject<bool> _showFolderIcon = BehaviorSubject.seeded(true);

  @override
  void setShowFolderIcon(final bool value) {
    unawaited(_sharedPreferences?.setBool(_showFolderIconKey, value));
    _showFolderIcon.add(value);
  }

  @override
  LatestStream<bool> get showEnabledModsFirst => vS2LS(_showEnabledModsFirst);
  final BehaviorSubject<bool> _showEnabledModsFirst =
      BehaviorSubject.seeded(false);

  @override
  void setShowEnabledModsFirst(final bool value) {
    unawaited(_sharedPreferences?.setBool(_showEnabledModsFirstKey, value));
    _showEnabledModsFirst.add(value);
  }

  @override
  LatestStream<String> get presetData => vS2LS(_presetData);
  final BehaviorSubject<String> _presetData = BehaviorSubject.seeded('123');

  @override
  void setPresetData(final String data) {
    unawaited(_sharedPreferences?.setString(_presetDatakey, data));
    _presetData.add(data);
  }

  @override
  void dispose() {
    unawaited(_modRoot.close());
    unawaited(_modExecFile.close());
    unawaited(_launcherFile.close());
    unawaited(_runTogether.close());
    unawaited(_moveOnDrag.close());
    unawaited(_showFolderIcon.close());
    unawaited(_showEnabledModsFirst.close());
    unawaited(_presetData.close());
  }

  @override
  void reload() {
    // ignore: discarded_futures
    successfulLoad = _getFuture();
  }

  Future<bool> _getFuture() => SharedPreferences.getInstance().timeout(
        _sharedPreferencesAwaitTime,
        onTimeout: () {
          throw TimeoutException(
            'Unable to obtain SharedPreference settings',
            _sharedPreferencesAwaitTime,
          );
        },
      ).then((final value) {
        _sharedPreferences = value;

        const dotString = '.';
        final tDirRaw = value.getString(_targetDirKey);
        final targetDir = tDirRaw ?? dotString;

        final mRootRaw = value.getString(_modRootKey);
        if (mRootRaw != null) {
          _modRoot.add(mRootRaw);
        }
        if (_modRoot.valueOrNull == dotString && targetDir != dotString) {
          setModRoot(targetDir.pJoin('Mods'));
        }

        final mExecRaw = value.getString(_modExecFileKey);
        if (mExecRaw != null) {
          _modExecFile.add(mExecRaw);
        }
        if (_modExecFile.valueOrNull == dotString && targetDir != dotString) {
          setModExecFile(targetDir.pJoin('3DMigoto Loader.exe'));
        }

        if (targetDir != dotString) {
          unawaited(_sharedPreferences?.setString(_targetDirKey, dotString));
        }

        final lFileRaw = value.getString(_launcherFileKey);
        if (lFileRaw != null) {
          _launcherFile.add(lFileRaw);
        }

        final runTogetherRaw = value.getBool(_runTogetherKey);
        if (runTogetherRaw != null) {
          _runTogether.add(runTogetherRaw);
        }

        final moveOnDragRaw = value.getBool(_moveOnDragKey);
        if (moveOnDragRaw != null) {
          _moveOnDrag.add(moveOnDragRaw);
        }

        final showFolderIconRaw = value.getBool(_showFolderIconKey);
        if (showFolderIconRaw != null) {
          _showFolderIcon.add(showFolderIconRaw);
        }

        final showEnabledModsFirstRaw = value.getBool(_showEnabledModsFirstKey);
        if (showEnabledModsFirstRaw != null) {
          _showEnabledModsFirst.add(showEnabledModsFirstRaw);
        }

        final presetDataRaw = value.getString(_presetDatakey);
        if (presetDataRaw != null) {
          _presetData.add(presetDataRaw);
        }

        return true;
      });

  @override
  String toString() => 'AppStateService{'
      'modRoot: $modRoot, '
      'modExecFile: $modExecFile, '
      'launcherFile: $launcherFile, '
      'runTogether: $runTogether, '
      'moveOnDrag: $moveOnDrag, '
      'showFolderIcon: $showFolderIcon, '
      'showEnabledModsFirst: $showEnabledModsFirst, '
      'presetData: $presetData}';
}
