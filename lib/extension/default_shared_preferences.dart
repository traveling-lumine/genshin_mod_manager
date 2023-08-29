import 'package:shared_preferences/shared_preferences.dart';

extension DefaultSharedPreferences on SharedPreferences {
  String getStringOrDot(String key) {
    return getString(key) ?? '.';
  }

  bool getBoolOrFalse(String key) {
    return getBool(key) ?? false;
  }

  bool getBoolOrTrue(String key) {
    return getBool(key) ?? true;
  }
}
