import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

const kAkashaConfigFilename = 'config.json';
const _base = "https://nahida.live";

class NahidaliveElement {
  final String uuid;
  final String version;
  final String title;
  final String description;
  final String? arcaUrl;
  final String? virustotalUrl;
  final UnmodifiableListView<String> tags;
  final String previewUrl;

  const NahidaliveElement({
    required this.uuid,
    required this.version,
    required this.title,
    required this.description,
    this.arcaUrl,
    this.virustotalUrl,
    required this.tags,
    required this.previewUrl,
  });

  factory NahidaliveElement.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'uuid': String uuid,
        'version': String version,
        'title': String title,
        'description': String description,
        'arca_url': String? arcaUrl,
        'virustotal_url': String? virustotalUrl,
        'tags': List<dynamic> tags,
        'preview_url': String previewUrl,
      } =>
        NahidaliveElement(
          uuid: uuid,
          version: version,
          title: title,
          description: description,
          arcaUrl: arcaUrl,
          virustotalUrl: virustotalUrl,
          tags: UnmodifiableListView(tags.cast<String>()),
          previewUrl: previewUrl,
        ),
      _ => throw FormatException('Unknown NahidaliveElement format: $json'),
    };
  }

  @override
  String toString() {
    return 'NahidaliveElement('
        'uuid: $uuid, '
        'version: $version, '
        'title: $title, '
        'description: $description, '
        'arcaUrl: $arcaUrl, '
        'virustotalUrl: $virustotalUrl, '
        'tags: $tags, '
        'previewUrl: $previewUrl, '
        ')';
  }
}

class NahidaliveDownloadElement {
  final bool status;
  final String? errorCodes;
  final String? downloadUrl;

  const NahidaliveDownloadElement({
    required this.status,
    this.errorCodes,
    this.downloadUrl,
  });

  factory NahidaliveDownloadElement.fromJson(Map<String, dynamic> json) {
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
      _ => throw const FormatException(
          'Unknown NahidaliveDownloadElement format.'),
    };
  }

  @override
  String toString() {
    return 'NahidaliveDownloadElement('
        'status: $status, '
        'errorCodes: $errorCodes, '
        'downloadUrl: $downloadUrl'
        ')';
  }
}

class NahidaliveAPI {
  final client = http.Client();

  Future<List<NahidaliveElement>> fetchNahidaliveElements() async {
    final response = await client.get(Uri.parse('$_base/mods/apiv2/list'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic json) => NahidaliveElement.fromJson(json))
          .toList();
    } else {
      throw Exception('fetch list failed');
    }
  }

  Future<NahidaliveElement> fetchNahidaliveElement(String uuid) async {
    final response =
        await client.get(Uri.parse('$_base/mods/apiv2/list?uuid=$uuid'));
    if (response.statusCode == 200) {
      return NahidaliveElement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('fetch element failed');
    }
  }

  Future<NahidaliveDownloadElement> downloadUrl(String uuid,
      {String? pw, String? updateCode}) async {
    final Uri uri;
    if (updateCode != null) {
      uri = Uri.parse(
          '$_base/mods/apiv2/download?uuid=$uuid&update_code=$updateCode');
    } else {
      if (pw != null) {
        uri = Uri.parse('$_base/mods/apiv2/download?uuid=$uuid&password=$pw');
      } else {
        uri = Uri.parse('$_base/mods/apiv2/download?uuid=$uuid');
      }
    }
    final response = await client.get(uri);
    if (response.statusCode == 200) {
      return NahidaliveDownloadElement.fromJson(jsonDecode(response.body));
    } else {
      throw HttpException('download url failed', uri: uri);
    }
  }

  Future<Uint8List> download(NahidaliveDownloadElement downloadElement) async {
    if (downloadElement.status) {
      final response =
          await client.get(Uri.parse(downloadElement.downloadUrl!));
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
