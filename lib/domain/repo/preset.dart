import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';

abstract interface class PresetService {
  LatestStream<List<String>> getLocalPresets(ModCategory category);

  LatestStream<List<String>> get globalPresets;

  void setLocalPreset(ModCategory category, String name);

  void setGlobalPreset(String name);

  void addLocalPreset(ModCategory category, String text);

  void addGlobalPreset(String text);

  void removeLocalPreset(ModCategory category, String name);

  void removeGlobalPreset(String name);

  void dispose();
}
