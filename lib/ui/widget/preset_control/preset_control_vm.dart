import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/preset.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class PresetControlViewModel implements BaseViewModel {
  List<String>? get presets;

  void setPreset(final String name);

  void addPreset(final String text);

  void removePreset(final String name);
}

PresetControlViewModel createGlobalPresetControlViewModel({
  required final PresetService presetService,
}) => _GlobalPresetControlViewModelImpl(presetService: presetService);

class _GlobalPresetControlViewModelImpl extends ChangeNotifier
    implements PresetControlViewModel {

  _GlobalPresetControlViewModelImpl({
    required this.presetService,
  }) : _presets = presetService.globalPresets.latest {
    _subscription = presetService.globalPresets.stream.listen((final value) {
      _presets = value;
      notifyListeners();
    });
  }
  late final StreamSubscription<List<String>> _subscription;
  final PresetService presetService;

  @override
  List<String>? get presets => _presets;
  List<String>? _presets;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void setPreset(final String name) {
    presetService.setGlobalPreset(name);
  }

  @override
  void addPreset(final String text) {
    presetService.addGlobalPreset(text);
  }

  @override
  void removePreset(final String name) {
    presetService.removeGlobalPreset(name);
  }
}

PresetControlViewModel createLocalPresetControlViewModel({
  required final PresetService presetService,
  required final ModCategory category,
}) => _LocalPresetControlViewModelImpl(
    presetService: presetService,
    category: category,
  );

class _LocalPresetControlViewModelImpl extends ChangeNotifier
    implements PresetControlViewModel {

  _LocalPresetControlViewModelImpl({
    required this.presetService,
    required this.category,
  }) : _presets = presetService.getLocalPresets(category).latest {
    _subscription =
        presetService.getLocalPresets(category).stream.listen((final value) {
      _presets = value;
      notifyListeners();
    });
  }
  late final StreamSubscription<List<String>> _subscription;
  final PresetService presetService;
  final ModCategory category;

  @override
  List<String>? get presets => _presets;
  List<String>? _presets;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void setPreset(final String name) {
    presetService.setLocalPreset(category, name);
  }

  @override
  void addPreset(final String text) {
    presetService.addLocalPreset(category, text);
  }

  @override
  void removePreset(final String name) {
    presetService.removeLocalPreset(category, name);
  }
}
