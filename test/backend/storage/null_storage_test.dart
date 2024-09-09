import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/backend/storage/data/repo/null_storage.dart';

void main() {
  late NullSharedPreferenceStorage nullStorage;
  setUp(() {
    nullStorage = NullSharedPreferenceStorage();
  });
  test('getBool', () {
    expect(nullStorage.getBool('key'), isNull);
  });
  test('setBool', () {
    nullStorage.setBool('key', true);
  });
  test('getString', () {
    expect(nullStorage.getString('key'), isNull);
  });
  test('setString', () {
    nullStorage.setString('key', 'value');
  });
  test('getMap', () {
    expect(nullStorage.getMap('key'), isNull);
  });
  test('setMap', () {
    nullStorage.setMap('key', <String, dynamic>{});
  });
  test('removeKey', () {
    nullStorage.removeKey('key');
  });
  test('getInt', () {
    expect(nullStorage.getInt('key'), isNull);
  });
  test('setInt', () {
    nullStorage.setInt('key', 42);
  });
  test('getEntries', () {
    expect(nullStorage.getEntries(), <String>{});
  });
  test('getList', () {
    expect(nullStorage.getList('key'), isNull);
  });
  test('setList', () {
    nullStorage.setList('key', <String>[]);
  });
}
