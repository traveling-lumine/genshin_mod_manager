import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/repo/preset.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';

abstract interface class PresetControlViewModel extends ChangeNotifier {
  List<String> get presets;

  void setPreset(String name);

  void addPreset(String text);

  void removePreset(String name);
}

PresetControlViewModel createGlobalPresetControlViewModel({
  required PresetService presetService,
}) {
  return _GlobalPresetControlViewModelImpl(presetService: presetService);
}

class _GlobalPresetControlViewModelImpl extends ChangeNotifier
    implements PresetControlViewModel {
  final PresetService _presetService;

  _GlobalPresetControlViewModelImpl({required PresetService presetService})
      : _presetService = presetService;

  @override
  List<String> get presets => _presetService.getGlobalPresets();

  @override
  void setPreset(String name) {
    _presetService.setGlobalPreset(name);
  }

  @override
  void addPreset(String text) {
    _presetService.addGlobalPreset(text);
    notifyListeners();
  }

  @override
  void removePreset(String name) {
    _presetService.removeGlobalPreset(name);
    notifyListeners();
  }
}

PresetControlViewModel createLocalPresetControlViewModel({
  required PresetService presetService,
  required ModCategory category,
}) {
  return _LocalPresetControlViewModelImpl(
    presetService: presetService,
    category: category,
  );
}

class _LocalPresetControlViewModelImpl extends ChangeNotifier
    implements PresetControlViewModel {
  final PresetService _presetService;
  final ModCategory _category;

  _LocalPresetControlViewModelImpl({
    required PresetService presetService,
    required ModCategory category,
  })  : _presetService = presetService,
        _category = category;

  @override
  List<String> get presets => _presetService.getLocalPresets(_category);

  @override
  void setPreset(String name) {
    _presetService.setLocalPreset(_category, name);
  }

  @override
  void addPreset(String text) {
    _presetService.addLocalPreset(_category, text);
    notifyListeners();
  }

  @override
  void removePreset(String name) {
    _presetService.removeLocalPreset(_category, name);
    notifyListeners();
  }
}
