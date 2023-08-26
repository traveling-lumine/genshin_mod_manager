import 'package:fluent_ui/fluent_ui.dart';

class AppState with ChangeNotifier {
  String _targetDir;
  String _launcherFile;
  bool _runTogether;

  String get targetDir => _targetDir;

  set targetDir(String value) {
    _targetDir = value;
    notifyListeners();
  }

  String get launcherFile => _launcherFile;

  set launcherFile(String value) {
    _launcherFile = value;
    notifyListeners();
  }

  bool get runTogether => _runTogether;

  set runTogether(bool value) {
    _runTogether = value;
    notifyListeners();
  }

  AppState(this._targetDir, this._launcherFile, this._runTogether);

  @override
  String toString() {
    return 'AppState(_targetDir: $_targetDir, _launcherDir: $_launcherFile)';
  }
}
