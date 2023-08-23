import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class AppState with ChangeNotifier {
  String _targetDir;
  String _launcherFile;

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

  AppState(this._targetDir, this._launcherFile);

  @override
  String toString() {
    return 'AppState{_targetDir: $_targetDir, _launcherDir: $_launcherFile}';
  }
}
