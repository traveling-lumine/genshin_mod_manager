import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:http/http.dart' as http;

/// The filename of Akasha's configuration file.
const kAkashaConfigFilename = 'config.json';
const _kAkashaBase = "https://nahida.live";
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
      final List<dynamic> body = jsonDecode(response.body);
      return List.unmodifiable(body.map(_neFromJson));
    } else {
      throw Exception('fetch list failed');
    }
  }

  @override
  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid) async {
    final response = await _client.get(Uri.parse('$_kAkashaList?uuid=$uuid'));
    if (response.statusCode == 200) {
      return _neFromJson(jsonDecode(response.body));
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
      return _ndeFromJson(jsonDecode(response.body));
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

NahidaliveElement _neFromJson(final json) => switch (json) {
      {
        'uuid': final String uuid,
        'version': final String version,
        'sha256': final String sha256,
        'title': final String title,
        'description': final String description,
        'arca_url': final String? arcaUrl,
        'virustotal_url': final String? virustotalUrl,
        'tags': final List<dynamic> tags,
        'expiration_date': final String? expirationDate,
        'upload_date': final String uploadDate,
        'preview_url': final String previewUrl,
        'koreaonly': final bool koreaonly,
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

NahidaliveDownloadElement _ndeFromJson(final Map<String, dynamic> json) =>
    switch (json) {
      {
        'status': final bool status,
        'download_url': final String downloadUrl,
      } =>
        NahidaliveDownloadElement(
          status: status,
          downloadUrl: downloadUrl,
        ),
      {
        'status': final bool status,
        'error-codes': final String errorCodes,
      } =>
        NahidaliveDownloadElement(
          status: status,
          errorCodes: errorCodes,
        ),
      _ => throw FormatException(
          'Unknown NahidaliveDownloadElement format: $json',
        ),
    };
