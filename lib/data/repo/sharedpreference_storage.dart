import 'dart:async';
import 'dart:convert';

import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceStorage implements PersistentStorage {
  const SharedPreferenceStorage(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  @override
  bool? getBool(final String key) => _sharedPreferences.getBool(key);

  @override
  void setBool(final String key, final bool value) {
    unawaited(_sharedPreferences.setBool(key, value));
  }

  @override
  String? getString(final String key) => _sharedPreferences.getString(key);

  @override
  void setString(final String key, final String value) {
    unawaited(_sharedPreferences.setString(key, value));
  }

  @override
  Map<String, dynamic>? getMap(final String key) {
    final string = _sharedPreferences.getString(key);
    if (string == null) {
      return null;
    }
    return jsonDecode(string);
  }

  @override
  void setMap(final String key, final Map<String, dynamic> value) {
    unawaited(_sharedPreferences.setString(key, jsonEncode(value)));
  }
}

class NullSharedPreferenceStorage implements PersistentStorage {
  @override
  bool? getBool(final String key) => null;

  @override
  void setBool(final String key, final bool value) {}

  @override
  String? getString(final String key) => null;

  @override
  void setString(final String key, final String value) {}

  @override
  Map<String, dynamic>? getMap(final String key) => null;

  @override
  void setMap(final String key, final Map<String, dynamic> value) {}
}
