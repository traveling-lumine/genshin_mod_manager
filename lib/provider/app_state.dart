import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extension/default_shared_preferences.dart';

class AppState with ChangeNotifier {
  static const String targetDirKey = 'targetDir';
  String _targetDir;

  String get targetDir => _targetDir;

  set targetDir(String value) {
    _targetDir = value;
    notifyListeners();
  }

  static const String launcherFileKey = 'launcherDir';
  String _launcherFile;

  String get launcherFile => _launcherFile;

  set launcherFile(String value) {
    _launcherFile = value;
    notifyListeners();
  }

  static const String runTogetherKey = 'runTogether';
  bool _runTogether;

  bool get runTogether => _runTogether;

  set runTogether(bool value) {
    _runTogether = value;
    notifyListeners();
  }

  static const String moveOnDragKey = 'moveOnDrag';
  bool _moveOnDrag;

  bool get moveOnDrag => _moveOnDrag;

  set moveOnDrag(bool value) {
    _moveOnDrag = value;
    notifyListeners();
  }

  static const String showFolderIconKey = 'showFolderIcon';
  bool _showFolderIcon;

  bool get showFolderIcon => _showFolderIcon;

  set showFolderIcon(bool value) {
    _showFolderIcon = value;
    notifyListeners();
  }

  AppState(
    this._targetDir,
    this._launcherFile,
    this._runTogether,
    this._moveOnDrag,
    this._showFolderIcon,
  );

  AppState.defaultState()
      : this(
          '.',
          '.',
          false,
          false,
          true,
        );

  @override
  String toString() {
    return 'AppState('
        '_targetDir: $_targetDir'
        ', _launcherFile: $_launcherFile'
        ', _runTogether: $_runTogether'
        ', _moveOnDrag: $_moveOnDrag'
        ', _showFolderIcon: $_showFolderIcon'
        ')';
  }
}

Future<AppState> getAppState() async {
  final instance = await SharedPreferences.getInstance();
  return AppState(
    instance.getStringOrDot(AppState.targetDirKey),
    instance.getStringOrDot(AppState.launcherFileKey),
    instance.getBoolOrFalse(AppState.runTogetherKey),
    instance.getBoolOrFalse(AppState.moveOnDragKey),
    instance.getBoolOrTrue(AppState.showFolderIconKey),
  );
}
