import 'package:fluent_ui/fluent_ui.dart';

class AppState with ChangeNotifier {
  String _targetDir;
  String _launcherDir;

  String get launcherDir => _launcherDir;

  set launcherDir(String value) {
    _launcherDir = value;
    notifyListeners();
  }

  String get targetDir => _targetDir;

  set targetDir(String value) {
    _targetDir = value;
    notifyListeners();
  }

  AppState(this._targetDir, this._launcherDir);

  @override
  String toString() {
    return 'AppState{_targetDir: $_targetDir, _launcherDir: $_launcherDir}';
  }
}
