import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/backend/storage/data/repo/sharedpreference_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferenceStorage storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferenceStorage(
      await SharedPreferences.getInstance(),
    );
  });
  group(
    'bool value',
    () {
      test('getBool', () {
        expect(storage.getBool('key'), isNull);
      });
      test('setBool', () {
        storage.setBool('key', true);
      });
      test('setBool and getBool', () {
        storage.setBool('key', true);
        expect(storage.getBool('key'), isTrue);
      });
    },
  );
  group(
    'string value',
    () {
      test('getString', () {
        expect(storage.getString('key'), isNull);
      });
      test('setString', () {
        storage.setString('key', 'value');
      });
      test('setString and getString', () {
        storage.setString('key', 'value');
        expect(storage.getString('key'), equals('value'));
      });
    },
  );
  group(
    'map value',
    () {
      test('getMap', () {
        expect(storage.getMap('key'), isNull);
      });
      test('setMap', () {
        storage.setMap('key', <String, dynamic>{});
      });
      test('setMap and getMap', () {
        storage.setMap('key', <String, dynamic>{'key': 'value'});
        expect(
          storage.getMap('key'),
          equals(<String, dynamic>{'key': 'value'}),
        );
      });
    },
  );
  group(
    'int value',
    () {
      test('getInt', () {
        expect(storage.getInt('key'), isNull);
      });
      test('setInt', () {
        storage.setInt('key', 42);
      });
      test('setInt and getInt', () {
        storage.setInt('key', 42);
        expect(storage.getInt('key'), equals(42));
      });
    },
  );
  group(
    'list value',
    () {
      test('getList', () {
        expect(storage.getList('key'), isNull);
      });
      test('setList', () {
        storage.setList('key', <String>[]);
      });
      test('setList and getList', () {
        storage.setList('key', <String>['value']);
        expect(storage.getList('key'), equals(<String>['value']));
      });
    },
  );
  group(
    'remove key',
    () {
      test('removeKey', () {
        storage
          ..setString('key', 'value')
          ..removeKey('key');
        expect(storage.getString('key'), isNull);
      });
    },
  );
  group(
    'get entries',
    () {
      test('getEntries', () {
        storage.setString('key', 'value');
        expect(storage.getEntries(), contains('key'));
      });
    },
  );
}
