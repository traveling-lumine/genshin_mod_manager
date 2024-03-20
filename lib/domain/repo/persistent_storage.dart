abstract interface class PersistentStorage {
  bool getBool(final String key);

  // ignore: avoid_positional_boolean_parameters
  void setBool(final String key, final bool value);

  String getString(final String key);

  void setString(final String key, final String value);

  Map<String, dynamic> getMap(final String key);

  void setMap(final String key, final Map<String, dynamic> value);
}
