import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/entity/download_element.dart';
import '../../domain/entity/nahida_element.dart';
import '../../domain/repo/akasha.dart';
import '../secrets.dart';

class NahidaliveAPIImpl implements NahidaliveAPI {
  final _client = http.Client();

  @override
  Future<List<NahidaliveElement>> fetchNahidaliveElements(
    final int pageNum,
  ) async {
    if (pageNum <= 0) {
      throw ArgumentError.value(pageNum, 'pageNum', 'must be greater than 0');
    }
    final response = await _client.get(
      Uri.https(
        Env.val10,
        Env.val12,
        {Env.val1: pageNum.toString(), Env.val2: Env.val5},
      ),
      headers: {Env.val9: Env.val8},
    );
    if (response.statusCode != 200) {
      throw Exception('fetch list failed: ${response.body}');
    }
    final jsonDecode2 = jsonDecode(response.body) as Map<String, dynamic>;
    final jsonDecode22 = jsonDecode2[Env.val3] as Map<String, dynamic>;
    final body = (jsonDecode22[Env.val4] as List).cast<Map<String, dynamic>>();
    final list = body.map(NahidaliveElement.fromJson).toList();
    return list;
  }

  @override
  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid) async {
    final response = await _client.get(
      Uri.https(
        Env.val10,
        '${Env.val13}/$uuid',
      ),
    );
    return NahidaliveElement.fromJson(
      (jsonDecode(response.body) as Map<String, dynamic>)['data']
          as Map<String, dynamic>,
    );
  }

  @override
  Future<NahidaliveDownloadElement> downloadUrl(
    final String uuid, {
    final String? pw,
    final String? updateCode,
  }) async {
    final queryParams = <String, String>{};
    if (updateCode != null) {
      queryParams[Env.val6] = updateCode;
    } else if (pw != null) {
      queryParams[Env.val7] = pw;
    }
    final Map<String, String>? queryMap;
    if (queryParams.isEmpty) {
      queryMap = null;
    } else {
      queryMap = queryParams;
    }

    final uri = Uri.https(Env.val10, '${Env.val11}/$uuid', queryMap);
    final response = await _client.post(
      uri,
      headers: {Env.val9: Env.val8},
      body: {Env.val7: pw ?? ''},
    );
    return NahidaliveDownloadElement.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<Uint8List> download(
    final NahidaliveDownloadElement downloadElement,
  ) async {
    final response = await _client.get(Uri.parse(downloadElement.downloadUrl!));
    if (response.statusCode != 200) {
      throw Exception('download failed');
    }
    return response.bodyBytes;
  }
}
