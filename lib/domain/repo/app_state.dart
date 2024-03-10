import 'package:flutter/foundation.dart';

abstract interface class AppStateService extends ChangeNotifier {
  abstract Future<bool> successfulLoad;

  abstract String modRoot;

  abstract String modExecFile;

  abstract String launcherFile;

  abstract bool runTogether;

  abstract bool moveOnDrag;

  abstract bool showFolderIcon;

  abstract bool showEnabledModsFirst;

  abstract String presetData;

  void init();
}
