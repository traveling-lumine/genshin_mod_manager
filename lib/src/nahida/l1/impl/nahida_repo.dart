import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../l0/api/nahida_repo.dart';
import '../../l0/entity/nahida_element.dart';
import '../../l0/entity/wrong_password.dart';
import '../api/nahida_api.dart';
import '../secrets.dart';

class NahidaRepoImpl implements NahidaRepository {
  const NahidaRepoImpl({
    required this.api,
  });
  final NahidaAPI api;

  @override
  Future<Uint8List> addDownload({
    required final NahidaliveElement element,
    required final String turnstile,
    final String? pw,
  }) async {
    final data = await api.getDownloadLink(
      uuid: element.uuid,
      pw: pw,
      turnstile: turnstile,
    );
    final url = data.downloadUrl;
    if (url == null) {
      throw const WrongPasswordException();
    }
    final dio = Dio();

    final response = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data!);
  }

  @override
  Future<NahidaliveElement> getNahidaElement({
    required final String uuid,
  }) async {
    final nahidaElement = await api.getNahidaElement(uuid: uuid);
    return nahidaElement.result;
  }

  @override
  Future<List<NahidaliveElement>> getNahidaElementPage({
    required final int pageNum,
    final int pageSize = 100,
  }) async {
    final nahidaElementPage = await api.getNahidaElementPage(
      pageNum: pageNum,
      authKey: Env.val8,
      pageSize: pageSize,
    );
    return nahidaElementPage.data!.elements;
  }
}
