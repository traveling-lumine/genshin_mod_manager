import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../l0/api/nahida.dart';
import '../../l0/entity/nahida_element.dart';
import '../api/nahida.dart';
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
    final dio = Dio();

    final response = await dio.get<List<int>>(
      url!,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(response.data!);
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

  @override
  Future<NahidaliveElement> getNahidaElement({
    required final String uuid,
  }) async {
    final nahidaElement = await api.getNahidaElement(uuid: uuid);
    return nahidaElement.result;
  }
}
