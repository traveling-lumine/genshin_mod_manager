import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repo/persistent_storage.dart';

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
    return jsonDecode(string) as Map<String, dynamic>;
  }

  @override
  void setMap(final String key, final Map<String, dynamic> value) {
    unawaited(_sharedPreferences.setString(key, jsonEncode(value)));
  }

  @override
  void removeKey(final String key) {
    unawaited(_sharedPreferences.remove(key));
  }

  @override
  int? getInt(final String key) => _sharedPreferences.getInt(key);

  @override
  void setInt(final String key, final int value) {
    unawaited(_sharedPreferences.setInt(key, value));
  }

  @override
  Set<String> getEntries() => _sharedPreferences.getKeys();

  @override
  List<String>? getList(final String key) =>
      _sharedPreferences.getStringList(key);

  @override
  void setList(final String key, final List<String> value) {
    unawaited(_sharedPreferences.setStringList(key, value));
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

  @override
  void removeKey(final String key) {}

  @override
  int? getInt(final String key) => null;

  @override
  void setInt(final String key, final int value) {}

  @override
  Set<String> getEntries() => <String>{};

  @override
  List<String>? getList(final String key) => null;

  @override
  void setList(final String key, final List<String> value) {}
}
