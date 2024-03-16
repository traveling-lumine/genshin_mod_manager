import 'dart:collection';

import 'package:meta/meta.dart';

@immutable
class NahidaliveElement {
  const NahidaliveElement({
    required this.uuid,
    required this.version,
    required this.title,
    required this.description,
    required this.tags,
    required this.previewUrl,
    this.arcaUrl,
    this.virustotalUrl,
  });

  final String uuid;
  final String version;
  final String title;
  final String description;
  final String? arcaUrl;
  final String? virustotalUrl;
  final UnmodifiableListView<String> tags;
  final String previewUrl;

  @override
  String toString() => 'NahidaliveElement('
      'uuid: $uuid, '
      'version: $version, '
      'title: $title, '
      'description: $description, '
      'arcaUrl: $arcaUrl, '
      'virustotalUrl: $virustotalUrl, '
      'tags: $tags, '
      'previewUrl: $previewUrl, '
      ')';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    // tag list equality check
    if (other is! NahidaliveElement) {
      return false;
    }
    var tagsEqual = true;
    if (tags.length != other.tags.length) {
      tagsEqual = false;
    } else {
      for (var i = 0; i < tags.length; i++) {
        if (tags[i] != other.tags[i]) {
          tagsEqual = false;
          break;
        }
      }
    }
    return other.uuid == uuid &&
        other.version == version &&
        other.title == title &&
        other.description == description &&
        other.arcaUrl == arcaUrl &&
        other.virustotalUrl == virustotalUrl &&
        tagsEqual &&
        other.previewUrl == previewUrl;
  }

  @override
  int get hashCode =>
      uuid.hashCode ^
      version.hashCode ^
      title.hashCode ^
      description.hashCode ^
      arcaUrl.hashCode ^
      virustotalUrl.hashCode ^
      tags.hashCode ^
      previewUrl.hashCode;
}

@immutable
class NahidaliveDownloadElement {
  const NahidaliveDownloadElement({
    required this.status,
    this.errorCodes,
    this.downloadUrl,
  });

  final bool status;
  final String? errorCodes;
  final String? downloadUrl;

  @override
  String toString() => 'NahidaliveDownloadElement('
      'status: $status, '
      'errorCodes: $errorCodes, '
      'downloadUrl: $downloadUrl'
      ')';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NahidaliveDownloadElement &&
        other.status == status &&
        other.errorCodes == errorCodes &&
        other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode =>
      status.hashCode ^ errorCodes.hashCode ^ downloadUrl.hashCode;
}
