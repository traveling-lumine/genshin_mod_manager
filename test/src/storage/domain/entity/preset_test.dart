import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'preset_test.freezed.dart';
part 'preset_test.g.dart';

void main() {
  test('A test for coverage tracking.', () {
    const data = PresetData(
      global: [
        GlobalPreset(
          name: 'global',
          presets: [
            GlobalCategoryPreset(
              categoryName: 'preset1',
              mods: ['mod1', 'mod2'],
            ),
            GlobalCategoryPreset(
              categoryName: 'preset2',
              mods: ['mod3', 'mod4'],
            ),
          ],
        ),
      ],
      local: [
        LocalPresetByCategory(
          categoryName: 'local',
          presets: [
            LocalPreset(
              name: 'preset3',
              mods: ['mod5', 'mod6'],
            ),
            LocalPreset(
              name: 'preset4',
              mods: ['mod7', 'mod8'],
            ),
          ],
        ),
      ],
    );
    print(const JsonEncoder.withIndent(' ').convert(data));
  });
}

@freezed
class PresetData with _$PresetData {
  const factory PresetData({
    required final List<GlobalPreset> global,
    required final List<LocalPresetByCategory> local,
  }) = _PresetData;

  factory PresetData.fromJson(final Map<String, dynamic> json) =>
      _$PresetDataFromJson(json);
}

@freezed
class GlobalPreset with _$GlobalPreset {
  const factory GlobalPreset({
    required final String name,
    required final List<GlobalCategoryPreset> presets,
  }) = _GlobalPreset;

  factory GlobalPreset.fromJson(final Map<String, dynamic> json) =>
      _$GlobalPresetFromJson(json);
}

@freezed
class GlobalCategoryPreset with _$GlobalCategoryPreset {
  const factory GlobalCategoryPreset({
    required final String categoryName,
    required final List<String> mods,
  }) = _GlobalCategoryPreset;

  factory GlobalCategoryPreset.fromJson(final Map<String, dynamic> json) =>
      _$GlobalCategoryPresetFromJson(json);
}

@freezed
class LocalPresetByCategory with _$LocalPresetByCategory {
  const factory LocalPresetByCategory({
    required final String categoryName,
    required final List<LocalPreset> presets,
  }) = _LocalPresetByCategory;

  factory LocalPresetByCategory.fromJson(final Map<String, dynamic> json) =>
      _$LocalPresetByCategoryFromJson(json);
}

@freezed
class LocalPreset with _$LocalPreset {
  const factory LocalPreset({
    required final String name,
    required final List<String> mods,
  }) = _LocalPreset;

  factory LocalPreset.fromJson(final Map<String, dynamic> json) =>
      _$LocalPresetFromJson(json);
}
