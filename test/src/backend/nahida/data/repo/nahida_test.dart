import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/backend/nahida/data/repo/nahida.dart';
import 'package:genshin_mod_manager/src/backend/nahida/domain/entity/nahida_element.dart';
import 'package:genshin_mod_manager/src/backend/nahida/domain/entity/wrong_password.dart';

const _passwdUuid = '734ae73e-dee7-477f-83d5-33e4f3cd0755';
const _nopasswdUuid = '54ff0249-831b-4ac4-b9b0-ba8d387bb13b';
const _passwd = 'sUpersecRetpassWord';

void main() {
  late NahidaliveAPIImpl api;
  setUp(() {
    api = NahidaliveAPIImpl();
  });
  group('Fetch page', () {
    test('Fetch page', () async {
      final result = await api.fetchNahidaliveElements(1);
      expect(result, isA<List<NahidaliveElement>>());
    });
    test('Fetch page 0 should throw', () async {
      expect(
        () async => api.fetchNahidaliveElements(0),
        throwsArgumentError,
      );
    });
  });
  test('Fetch single', () async {
    final result = await api.fetchNahidaliveElements(1);
    expect(result, isNotEmpty);
    final singleUuid = result.first.uuid;
    final singleResult = await api.fetchNahidaliveElement(singleUuid);
    expect(singleResult, isA<NahidaliveElement>());
    expect(singleResult.uuid, equals(result.first.uuid));
  });
  group('Download uuid', () {
    group('Password protected', () {
      test('Download uuid with password', () async {
        final result = await api.downloadUuid(uuid: _passwdUuid, pw: _passwd);
        expect(result, isA<Uint8List>());
      });
      test('Download uuid with wrong password', () async {
        expect(
          () async => api.downloadUuid(uuid: _passwdUuid, pw: 'wrongpassword'),
          throwsA(isA<WrongPasswordException>()),
        );
      });
    });
    group('No password', () {
      test('Download uuid without password', () async {
        final result = await api.downloadUuid(uuid: _nopasswdUuid);
        expect(result, isA<Uint8List>());
      });
      test('Download uuid with password should work also', () async {
        final result = await api.downloadUuid(uuid: _nopasswdUuid, pw: _passwd);
        expect(result, isA<Uint8List>());
      });
    });
  });
}
