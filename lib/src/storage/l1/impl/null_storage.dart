import '../../l0/api/persistent_storage.dart';

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
