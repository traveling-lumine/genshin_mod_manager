import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/entity/download_element.dart';
import '../../domain/entity/nahida_element.dart';
import '../../domain/entity/wrong_password.dart';
import '../../domain/repo/nahida.dart';
import '../entity/nahida_page_fetch_result.dart';
import '../entity/nahida_single_fetch_result.dart';
import '../secrets.dart';

class NahidaliveAPIImpl implements NahidaliveAPI {
  @override
  Future<Uint8List> downloadUuid({
    required final String uuid,
    final String? pw,
  }) async {
    final elem = await _downloadUrl(uuid, pw: pw);
    if (!elem.success) {
      throw const WrongPasswordException();
    }
    return _download(elem);
  }

  @override
  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid) async {
    final response = await http.get(Uri.https(Env.val10, '${Env.val13}/$uuid'));
    final fetchResult = NahidaSingleFetchResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    return fetchResult.result;
  }

  @override
  Future<List<NahidaliveElement>> fetchNahidaliveElements(
    final int pageNum,
  ) async {
    if (pageNum <= 0) {
      throw ArgumentError.value(pageNum, 'pageNum', 'must be greater than 0');
    }
    final response = await http.get(
      Uri.https(Env.val10, Env.val12, {
        Env.val1: pageNum.toString(),
        Env.val2: Env.val5,
      }),
      headers: {Env.val9: Env.val8},
    );
    final body = response.body;
    if (response.statusCode != 200) {
      throw Exception('fetch list failed: $body');
    }
    final fetchResult = NahidaPageFetchResult.fromJson(
      jsonDecode(body) as Map<String, dynamic>,
    );
    return fetchResult.result.elements;
  }

  Future<Uint8List> _download(
    final NahidaliveDownloadElement downloadElement,
  ) async {
    final response = await http.get(Uri.parse(downloadElement.downloadUrl!));
    if (response.statusCode != 200) {
      throw Exception('download failed');
    }
    return response.bodyBytes;
  }

  Future<NahidaliveDownloadElement> _downloadUrl(
    final String uuid, {
    final String? pw,
  }) async {
    final passwd =
        pw == null || pw.isEmpty ? <String, String>{} : {Env.val7: pw};
    final uri = Uri.https(Env.val10, '${Env.val11}/$uuid');
    final response = await http.post(uri, body: passwd);
    return NahidaliveDownloadElement.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
