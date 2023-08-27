import 'package:fluent_ui/fluent_ui.dart';

class AppState with ChangeNotifier {
  String _targetDir;
  String _launcherFile;
  bool _runTogether;
  bool _moveOnDrag;
  bool _showFolderIcon;

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

  bool get moveOnDrag => _moveOnDrag;

  set moveOnDrag(bool value) {
    _moveOnDrag = value;
    notifyListeners();
  }

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

  @override
  String toString() {
    return 'AppState('
        '_targetDir: $_targetDir'
        ', _launcherDir: $_launcherFile'
        ', _runTogether: $_runTogether'
        ', _moveOnDrag: $_moveOnDrag'
        ', _showFolderIcon: $_showFolderIcon'
        ')';
  }
}
