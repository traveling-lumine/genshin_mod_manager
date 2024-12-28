import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../mod_writer/domain/mod_writer.dart';
import '../entity/nahida_element.dart';
import '../repo/nahida.dart';

Future<void> nahidaDownloadUrlUseCase({
  required final NahidaliveAPI api,
  required final NahidaliveElement element,
  required final ModWriter writer,
  required final String turnstile,
  final String? pw,
}) async {
  final data =
      await api.downloadUuid(uuid: element.uuid, pw: pw, turnstile: turnstile);
  final url = data.downloadUrl;
  final dio = Dio();

  final response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );

  final responseData = Uint8List.fromList(response.data!);

  await writer(
    modName: element.title,
    data: responseData,
  );
}
