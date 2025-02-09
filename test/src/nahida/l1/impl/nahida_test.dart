import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/nahida/l0/entity/download_element.dart';
import 'package:genshin_mod_manager/src/nahida/l0/entity/nahida_element.dart';
import 'package:genshin_mod_manager/src/nahida/l1/api/nahida_api.dart';
import 'package:genshin_mod_manager/src/nahida/l1/entity/nahida_page_result.dart';
import 'package:genshin_mod_manager/src/nahida/l1/entity/nahida_single_fetch_result.dart';
import 'package:genshin_mod_manager/src/nahida/l1/impl/nahida_repo.dart';

const _elem = NahidaliveElement(
  uuid: 'uuid',
  version: '1.0.0',
  title: 'Title',
  tags: <String>['tag1', 'tag2'],
  previewUrl: 'https://example.com/preview',
  password: false,
);

const _elem2 = NahidaliveElement(
  uuid: 'uuid2',
  version: '1.0.0',
  title: 'Title2',
  tags: <String>['tag1', 'tag2'],
  previewUrl: 'https://example.com/preview',
  password: true,
);

final class MockAPI implements NahidaAPI {
  @override
  Future<NahidaDownloadUrlElement> getDownloadLink({
    required final String uuid,
    required final String turnstile,
    final String? pw,
  }) {
    if (turnstile != 'turnstile') {
      throw ArgumentError.value(
        turnstile,
        'turnstile',
        'Only "turnstile" is supported',
      );
    }
    var correctPw = true;
    if (uuid == 'uuid2' && pw != 'pw') {
      correctPw = false;
    }
    if (!correctPw) {
      return Future.value(
        const NahidaDownloadUrlElement(
          success: false,
          error: NahidaDownloadUrlError(
            code: 'incorrect_password',
            message: 'Incorrect password',
          ),
        ),
      );
    }
    return Future.value(
      const NahidaDownloadUrlElement(
        success: true,
        downloadUrl: 'https://sample-videos.com/zip/10mb.zip',
      ),
    );
  }

  @override
  Future<NahidaSingleFetchResult> getNahidaElement({
    required final String uuid,
  }) =>
      Future.value(
        const NahidaSingleFetchResult(
          result: _elem,
          success: true,
        ),
      );

  @override
  Future<NahidaPageQueryResult> getNahidaElementPage({
    required final int pageNum,
    required final String authKey,
    final int pageSize = 100,
  }) {
    if (pageSize != 2) {
      throw ArgumentError.value(pageSize, 'pageSize', 'Only 2 is supported');
    }
    return Future.value(
      NahidaPageQueryResult(
        data: NahidaPageResult(
          elementsPerPage: pageSize,
          currentPage: pageNum,
          totalPage: 1,
          totalElements: 1,
          elements: <NahidaliveElement>[_elem, _elem2],
        ),
        success: true,
      ),
    );
  }
}

void main() {
  test('nahida repo addDownload', () async {
    final repo = NahidaRepoImpl(api: MockAPI());
    final result = await repo.addDownload(
      element: _elem,
      turnstile: 'turnstile',
    );
    expect(result, isA<Uint8List>());
  });
  test('nahida repo getNahidaElementPage', () async {
    final repo = NahidaRepoImpl(api: MockAPI());
    final result = await repo.getNahidaElementPage(
      pageNum: 1,
      pageSize: 2,
    );
    expect(
      result,
      isA<List<NahidaliveElement>>()
          .having((final e) => e.length, 'length', 2)
          .having((final e) => e[0], 'uuid', equals(_elem))
          .having((final e) => e[1], 'uuid', equals(_elem2)),
    );
  });
  test('nahida repo getNahidaElement', () async {
    final repo = NahidaRepoImpl(api: MockAPI());
    final result = await repo.getNahidaElement(
      uuid: 'uuid',
    );
    expect(result, equals(_elem));
  });
}
