import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/preset.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class PresetControlViewModel implements BaseViewModel {
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
  late final StreamSubscription<List<String>> _subscription;
  final PresetService presetService;

  @override
  List<String> get presets => UnmodifiableListView(_presets);
  List<String> _presets;

  _GlobalPresetControlViewModelImpl({
    required this.presetService,
  }) : _presets = presetService.globalPresets.latest {
    _subscription = presetService.globalPresets.stream.listen((value) {
      _presets = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void setPreset(String name) {
    presetService.setGlobalPreset(name);
  }

  @override
  void addPreset(String text) {
    presetService.addGlobalPreset(text);
  }

  @override
  void removePreset(String name) {
    presetService.removeGlobalPreset(name);
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
  late final StreamSubscription<List<String>> _subscription;
  final PresetService presetService;
  final ModCategory category;

  @override
  List<String> get presets => UnmodifiableListView(_presets);
  List<String> _presets;

  _LocalPresetControlViewModelImpl({
    required this.presetService,
    required this.category,
  }) : _presets = presetService.getLocalPresets(category).latest {
    _subscription =
        presetService.getLocalPresets(category).stream.listen((value) {
      _presets = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void setPreset(String name) {
    presetService.setLocalPreset(category, name);
  }

  @override
  void addPreset(String text) {
    presetService.addLocalPreset(category, text);
  }

  @override
  void removePreset(String name) {
    presetService.removeLocalPreset(category, name);
  }
}
