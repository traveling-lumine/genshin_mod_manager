import 'dart:collection';

class NahidaliveElement {
  final String uuid;
  final String version;
  final String sha256;
  final String title;
  final String description;
  final String? arcaUrl;
  final String? virustotalUrl;
  final UnmodifiableListView<String> tags;
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
  final String? downloadUrl;

  const NahidaliveDownloadElement({
    required this.status,
    this.errorCodes,
    this.downloadUrl,
  });

  @override
  String toString() {
    return 'NahidaliveDownloadElement('
        'status: $status, '
        'errorCodes: $errorCodes, '
        'downloadUrl: $downloadUrl'
        ')';
  }
}
