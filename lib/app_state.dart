import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class AppState with ChangeNotifier {
  Directory _targetDir;
  File _launcherFile;

  Directory get targetDir => _targetDir;

  set targetDir(Directory value) {
    _targetDir = value;
    notifyListeners();
  }

  File get launcherFile => _launcherFile;

  set launcherFile(File value) {
    _launcherFile = value;
    notifyListeners();
  }

  AppState(this._targetDir, this._launcherFile);

  @override
  String toString() {
    return 'AppState{_targetDir: $_targetDir, _launcherDir: $_launcherFile}';
  }
}
