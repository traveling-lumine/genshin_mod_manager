import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:http/http.dart' as http;

const kAkashaConfigFilename = 'config.json';
const _kAkashaBase = "https://nahida.live";
const _kAkashaApi = '$_kAkashaBase/mods/apiv2';
const _kAkashaDownload = '$_kAkashaApi/download';
const _kAkashaList = '$_kAkashaApi/list';

NahidaliveAPI createNahidaliveAPI() {
  return _NahidaliveAPIImpl();
}

class _NahidaliveAPIImpl implements NahidaliveAPI {
  final _client = http.Client();

  @override
  Future<List<NahidaliveElement>> fetchNahidaliveElements() async {
    final response = await _client.get(Uri.parse(_kAkashaList));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return List.unmodifiable(body.map(_neFromJson));
    } else {
      throw Exception('fetch list failed');
    }
  }

  @override
  Future<NahidaliveElement> fetchNahidaliveElement(String uuid) async {
    final response = await _client.get(Uri.parse('$_kAkashaList?uuid=$uuid'));
    if (response.statusCode == 200) {
      return _neFromJson(jsonDecode(response.body));
    } else {
      throw Exception('fetch element failed');
    }
  }

  @override
  Future<NahidaliveDownloadElement> downloadUrl(String uuid,
      {String? pw, String? updateCode}) async {
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
      return _ndeFromJson(jsonDecode(response.body));
    } else {
      throw HttpException('download url failed', uri: uri);
    }
  }

  @override
  Future<Uint8List> download(NahidaliveDownloadElement downloadElement) async {
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

NahidaliveElement _neFromJson(dynamic json) {
  return switch (json) {
    {
      'uuid': String uuid,
      'version': String version,
      'sha256': String sha256,
      'title': String title,
      'description': String description,
      'arca_url': String? arcaUrl,
      'virustotal_url': String? virustotalUrl,
      'tags': List<dynamic> tags,
      'expiration_date': String? expirationDate,
      'upload_date': String uploadDate,
      'preview_url': String previewUrl,
      'koreaonly': bool koreaonly,
    } =>
      NahidaliveElement(
        uuid: uuid,
        version: version,
        sha256: sha256,
        title: title,
        description: description,
        arcaUrl: arcaUrl,
        virustotalUrl: virustotalUrl,
        tags: UnmodifiableListView(tags.cast<String>()),
        expirationDate: expirationDate,
        uploadDate: uploadDate,
        previewUrl: previewUrl,
        koreaOnly: koreaonly,
      ),
    _ => throw const FormatException('Unknown NahidaliveElement format.'),
  };
}

NahidaliveDownloadElement _ndeFromJson(Map<String, dynamic> json) {
  return switch (json) {
    {
      'status': bool status,
      'download_url': String downloadUrl,
    } =>
      NahidaliveDownloadElement(
        status: status,
        downloadUrl: downloadUrl,
      ),
    {
      'status': bool status,
      'error-codes': String errorCodes,
    } =>
      NahidaliveDownloadElement(
        status: status,
        errorCodes: errorCodes,
      ),
    _ =>
      throw FormatException('Unknown NahidaliveDownloadElement format: $json'),
  };
}
