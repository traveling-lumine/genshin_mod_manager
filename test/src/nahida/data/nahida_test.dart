import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/nahida/l1/entity/nahida_page_result.dart';
import 'package:genshin_mod_manager/src/nahida/l1/entity/nahida_single_fetch_result.dart';
import 'package:genshin_mod_manager/src/nahida/l2/impl/nahida_api.dart';
import 'package:genshin_mod_manager/src/nahida/l1/secrets.dart';
import 'package:genshin_mod_manager/src/nahida/l0/entity/download_element.dart';

const _passwdUuid = '734ae73e-dee7-477f-83d5-33e4f3cd0755';
const _nopasswdUuid = '54ff0249-831b-4ac4-b9b0-ba8d387bb13b';
const _passwd = 'sUpersecRetpassWord';

void main() {
  late NahidaAPIImpl api;
  setUp(() {
    final dio = Dio();
    dio.options.validateStatus = (final status) => true;
    api = NahidaAPIImpl(dio);
  });
  group('Fetch page', () {
    test('Fetch page', () async {
      final result =
          await api.getNahidaElementPage(pageNum: 1, authKey: Env.val8);
      expect(result, isA<NahidaPageQueryResult>());
    });
    test('Fetch page 0 should throw', () async {
      expect(
        () async => api.getNahidaElementPage(pageNum: 0, authKey: Env.val8),
        throwsA(isA<DioException>()),
      );
    });
  });
  test('Fetch single', () async {
    final result =
        (await api.getNahidaElementPage(pageNum: 1, authKey: Env.val8)).data!;
    expect(result.elements, isNotEmpty);
    final singleUuid = result.elements.first.uuid;
    final singleResult = await api.getNahidaElement(uuid: singleUuid);
    expect(singleResult, isA<NahidaSingleFetchResult>());
    expect(singleResult.result.uuid, equals(result.elements.first.uuid));
  });
  group('Download uuid', () {
    group('Password protected', () {
      test('Download uuid with password', () async {
        final result = await api.getDownloadLink(
          uuid: _passwdUuid,
          pw: _passwd,
          turnstile: '',
        );
        expect(
          result,
          isA<NahidaDownloadUrlElement>()
              .having((final p0) => p0.downloadUrl, 'error', isNotNull),
        );
      });
      test('Download uuid with wrong password', () async {
        final response = await api.getDownloadLink(
          uuid: _passwdUuid,
          pw: 'wrongpassword',
          turnstile: '',
        );
        expect(
          response,
          isA<NahidaDownloadUrlElement>()
              .having((final p0) => p0.error, 'error', isNotNull),
        );
      });
    });
    group('No password', () {
      test('Download uuid without password', () async {
        final result = await api.getDownloadLink(
          uuid: _nopasswdUuid,
          turnstile: '',
        );
        expect(
          result,
          isA<NahidaDownloadUrlElement>()
              .having((final p0) => p0.downloadUrl, 'error', isNotNull),
        );
      });
      test('Download uuid with password should work also', () async {
        final result = await api.getDownloadLink(
          uuid: _nopasswdUuid,
          pw: _passwd,
          turnstile: '',
        );
        expect(
          result,
          isA<NahidaDownloadUrlElement>()
              .having((final p0) => p0.downloadUrl, 'error', isNotNull),
        );
      });
    });
  });
}
