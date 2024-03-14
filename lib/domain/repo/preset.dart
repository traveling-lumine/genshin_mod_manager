import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';

abstract interface class PresetService {
  LatestStream<List<String>> getLocalPresets(final ModCategory category);

  LatestStream<List<String>> get globalPresets;

  void setLocalPreset(final ModCategory category, final String name);

  void setGlobalPreset(final String name);

  void addLocalPreset(final ModCategory category, final String text);

  void addGlobalPreset(final String text);

  void removeLocalPreset(final ModCategory category, final String name);

  void removeGlobalPreset(final String name);

  void dispose();
}
