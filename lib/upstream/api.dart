import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

const _base = "https://nahida.live";

class NahidaliveElement {
  final String uuid;
  final String version;
  final String sha256;
  final String title;
  final String description;
  final String? arcaUrl;
  final String? virustotalUrl;
  final List<String> tags;
  final String? expirationDate;
  final String uploadDate;
  final String previewUrl;
  final bool koreaOnly;

  const NahidaliveElement({
    required this.uuid,
    required this.version,
    required this.sha256,
    required this.title,
    required this.description,
    this.arcaUrl,
    this.virustotalUrl,
    required this.tags,
    this.expirationDate,
    required this.uploadDate,
    required this.previewUrl,
    required this.koreaOnly,
  });

  factory NahidaliveElement.fromJson(Map<String, dynamic> json) {
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
          tags: tags.cast<String>(),
          expirationDate: expirationDate,
          uploadDate: uploadDate,
          previewUrl: previewUrl,
          koreaOnly: koreaonly,
        ),
      _ => throw const FormatException('Unknown NahidaliveElement format.'),
    };
  }

  @override
  String toString() {
    return 'NahidaliveElement('
        'uuid: $uuid, '
        'version: $version, '
        'sha256: $sha256, '
        'title: $title, '
        'description: $description, '
        'arcaUrl: $arcaUrl, '
        'virustotalUrl: $virustotalUrl, '
        'tags: $tags, '
        'expirationDate: $expirationDate, '
        'uploadDate: $uploadDate, '
        'previewUrl: $previewUrl, '
        'koreaOnly: $koreaOnly'
        ')';
  }
}

class NahidaliveDownloadElement {
  final bool status;
  final String? errorCodes;
  final String? message;
  final String? downloadUrl;

  const NahidaliveDownloadElement({
    required this.status,
    this.errorCodes,
    this.message,
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
        'message': String message,
      } =>
        NahidaliveDownloadElement(
          status: status,
          errorCodes: errorCodes,
          message: message,
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
        'message: $message, '
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

  Future<NahidaliveDownloadElement> downloadUrl(String uuid, String pw) async {
    final response = await client
        .get(Uri.parse('$_base/mods/apiv2/download?uuid=$uuid&password=$pw'));
    if (response.statusCode == 200) {
      return NahidaliveDownloadElement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('download url failed');
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
