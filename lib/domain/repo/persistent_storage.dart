abstract interface class PersistentStorage {
  bool? getBool(final String key);

  void setBool(final String key, final bool value);

  int? getInt(final String key);

  void setInt(final String key, final int value);

  String? getString(final String key);

  void setString(final String key, final String value);

  Map<String, dynamic>? getMap(final String key);

  void setMap(final String key, final Map<String, dynamic> value);

  List<String>? getList(final String key);

  void setList(final String key, final List<String> value);

  void removeKey(final String key);

  Set<String> getEntries();
}
