import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:http/http.dart' as http;

/// The filename of Akasha's configuration file.
const kAkashaConfigFilename = 'config.json';
const _kAkashaBase = "https://api.nahida.live";
const _kAkashaApi = '$_kAkashaBase/mods/apiv2';
const _kAkashaDownload = '$_kAkashaApi/download';
const _kAkashaList = '$_kAkashaApi/list';

/// Creates a new [NahidaliveAPI] instance.
NahidaliveAPI createNahidaliveAPI() => _NahidaliveAPIImpl();

class _NahidaliveAPIImpl implements NahidaliveAPI {
  final _client = http.Client();

  @override
  Future<List<NahidaliveElement>> fetchNahidaliveElements() async {
    final response = await _client.get(Uri.parse(_kAkashaList));
    if (response.statusCode == 200) {
      final body = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      final list = body.map(NahidaliveElement.fromJson).toList();
      return list;
    } else {
      throw Exception('fetch list failed');
    }
  }

  @override
  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid) async {
    final response = await _client.get(Uri.parse('$_kAkashaList?uuid=$uuid'));
    if (response.statusCode == 200) {
      return NahidaliveElement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('fetch element failed');
    }
  }

  @override
  Future<NahidaliveDownloadElement> downloadUrl(
    final String uuid, {
    final String? pw,
    final String? updateCode,
  }) async {
    final Uri uri;
    if (updateCode != null) {
      uri = Uri.parse('$_kAkashaDownload?uuid=$uuid&update_code=$updateCode');
    } else {
      if (pw != null) {
        uri = Uri.parse('$_kAkashaDownload?uuid=$uuid&password=$pw');
      } else {
        uri = Uri.parse('$_kAkashaDownload?uuid=$uuid');
      }
    }
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return NahidaliveDownloadElement.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException('download url failed', uri: uri);
    }
  }

  @override
  Future<Uint8List> download(
    final NahidaliveDownloadElement downloadElement,
  ) async {
    if (downloadElement.status) {
      final response =
          await _client.get(Uri.parse(downloadElement.downloadUrl!));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('download failed');
      }
    } else {
      throw Exception('Wrong download element status');
    }
  }
}
