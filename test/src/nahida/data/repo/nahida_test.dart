import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/nahida/data/entity/nahida_page_result.dart';
import 'package:genshin_mod_manager/src/nahida/data/repo/nahida.dart';
import 'package:genshin_mod_manager/src/nahida/data/secrets.dart';
import 'package:genshin_mod_manager/src/nahida/domain/entity/nahida_element.dart';
import 'package:genshin_mod_manager/src/nahida/domain/entity/wrong_password.dart';

const _passwdUuid = '734ae73e-dee7-477f-83d5-33e4f3cd0755';
const _nopasswdUuid = '54ff0249-831b-4ac4-b9b0-ba8d387bb13b';
const _passwd = 'sUpersecRetpassWord';

void main() {
  late NahidaliveAPIImpl api;
  setUp(() {
    final dio = Dio();
    dio.options.validateStatus = (final status) => true;
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (final response, final handler) {
          final data = response.data as Map;
          if (data['success'] as bool) {
            final dataMap = data['data'] ??= data['mod'] ??= data;
            response.data = dataMap;
            return handler.next(response);
          } else {
            throw const WrongPasswordException();
          }
        },
      ),
    );
    api = NahidaliveAPIImpl(dio);
  });
  group('Fetch page', () {
    test('Fetch page', () async {
      final result =
          await api.fetchNahidaliveElements(pageNum: 1, authKey: Env.val8);
      expect(result, isA<NahidaPageResult>());
    });
    test('Fetch page 0 should throw', () async {
      expect(
        () async => api.fetchNahidaliveElements(pageNum: 0, authKey: Env.val8),
        throwsA(isA<DioException>()),
      );
    });
  });
  test('Fetch single', () async {
    final result =
        await api.fetchNahidaliveElements(pageNum: 1, authKey: Env.val8);
    expect(result.elements, isNotEmpty);
    final singleUuid = result.elements.first.uuid;
    final singleResult = await api.fetchNahidaliveElement(uuid: singleUuid);
    expect(singleResult, isA<NahidaliveElement>());
    expect(singleResult.uuid, equals(result.elements.first.uuid));
  });
  group('Download uuid', () {
    group('Password protected', () {
      test('Download uuid with password', () async {
        final result = await api.downloadUuid(
          uuid: _passwdUuid,
          pw: _passwd,
          turnstile: '',
        );
        expect(result, isA<Uint8List>());
      });
      test('Download uuid with wrong password', () async {
        expect(
          () async => api.downloadUuid(
            uuid: _passwdUuid,
            pw: 'wrongpassword',
            turnstile: '',
          ),
          throwsA(
            isA<DioException>().having(
              (final e) => e.error,
              'Error type',
              isA<WrongPasswordException>(),
            ),
          ),
        );
      });
    });
    group('No password', () {
      test('Download uuid without password', () async {
        final result =
            await api.downloadUuid(uuid: _nopasswdUuid, turnstile: '');
        expect(result, isA<Uint8List>());
      });
      test('Download uuid with password should work also', () async {
        final result = await api.downloadUuid(
          uuid: _nopasswdUuid,
          pw: _passwd,
          turnstile: '',
        );
        expect(result, isA<Uint8List>());
      });
    });
  });
}
