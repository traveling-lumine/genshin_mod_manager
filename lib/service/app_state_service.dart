import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/default_shared_preferences.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService with ChangeNotifier {
  static const Duration sharedPreferencesAwaitTime = Duration(seconds: 5);

  static const String targetDirKey = 'targetDir';
  static const String launcherFileKey = 'launcherDir';
  static const String runTogetherKey = 'runTogether';
  static const String moveOnDragKey = 'moveOnDrag';
  static const String showFolderIconKey = 'showFolderIcon';

  SharedPreferences? _sharedPreferences;
  PathString _targetDir = const PathString('.');
  PathString _launcherFile = const PathString('.');
  bool _runTogether = false;
  bool _moveOnDrag = false;
  bool _showFolderIcon = true;
  late Future<SharedPreferences> _initFuture;

  Future<SharedPreferences> get initFuture => _initFuture;

  PathString get targetDir => _targetDir;

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
      _targetDir = PathString(value.getStringOrDot(targetDirKey));
      _launcherFile = PathString(value.getStringOrDot(launcherFileKey));
      _runTogether = value.getBoolOrFalse(runTogetherKey);
      _moveOnDrag = value.getBoolOrFalse(moveOnDragKey);
      _showFolderIcon = value.getBoolOrTrue(showFolderIconKey);
      notifyListeners();
      return value;
    });
  }

  set initFuture(Future<SharedPreferences> value) {
    _initFuture = value;
    notifyListeners();
  }

  set targetDir(PathString value) {
    _sharedPreferences?.setString(targetDirKey, value.asString);
    _targetDir = value;
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
        'targetDir: $targetDir, '
        'launcherFile: $launcherFile, '
        'runTogether: $runTogether, '
        'moveOnDrag: $moveOnDrag, '
        'showFolderIcon: $showFolderIcon}';
  }
}
