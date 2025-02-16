import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceStorage {
  const SharedPreferenceStorage(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  bool? getBool(final String key) => _sharedPreferences.getBool(key);

  void setBool(final String key, final bool value) {
    unawaited(_sharedPreferences.setBool(key, value));
  }

  String? getString(final String key) => _sharedPreferences.getString(key);

  void setString(final String key, final String value) {
    unawaited(_sharedPreferences.setString(key, value));
  }

  Map<String, dynamic>? getMap(final String key) {
    final string = _sharedPreferences.getString(key);
    if (string == null) {
      return null;
    }
    return jsonDecode(string) as Map<String, dynamic>;
  }

  void setMap(final String key, final Map<String, dynamic> value) {
    unawaited(_sharedPreferences.setString(key, jsonEncode(value)));
  }

  void removeKey(final String key) {
    unawaited(_sharedPreferences.remove(key));
  }

  int? getInt(final String key) => _sharedPreferences.getInt(key);

  void setInt(final String key, final int value) {
    unawaited(_sharedPreferences.setInt(key, value));
  }

  Set<String> getEntries() => _sharedPreferences.getKeys();

  List<String>? getList(final String key) =>
      _sharedPreferences.getStringList(key);

  void setList(final String key, final List<String> value) {
    unawaited(_sharedPreferences.setStringList(key, value));
  }
}
