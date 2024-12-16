import 'package:freezed_annotation/freezed_annotation.dart';

part 'version.freezed.dart';

@freezed
class Version with _$Version {
  factory Version({
    required final int major,
    required final int minor,
    required final int patch,
    final int? build,
  }) = _Version;

  factory Version.parse(final String version) {
    // x.y.z or x.y.z+b
    // throws ArgumentError if invalid
    final parts = version.split('+');
    if (parts.length > 2) {
      throw ArgumentError.value(version, 'version', 'Invalid version format');
    }
    final build = parts.length == 2 ? int.parse(parts[1]) : null;
    final versionParts = parts[0].split('.');
    if (versionParts.length != 3) {
      throw ArgumentError.value(version, 'version', 'Invalid version format');
    }
    return Version(
      major: int.parse(versionParts[0]),
      minor: int.parse(versionParts[1]),
      patch: int.parse(versionParts[2]),
      build: build,
    );
  }

  const Version._();

  String get formatted =>
      '$major.$minor.$patch${build != null ? '+$build' : ''}';

  bool operator >(final Version other) {
    if (major > other.major) {
      return true;
    }
    if (major < other.major) {
      return false;
    }
    if (minor > other.minor) {
      return true;
    }
    if (minor < other.minor) {
      return false;
    }
    if (patch > other.patch) {
      return true;
    }
    if (patch < other.patch) {
      return false;
    }
    final thisBuild = build;
    if (thisBuild == null) {
      return false;
    }
    final otherBuild = other.build;
    if (otherBuild == null) {
      return true;
    }
    return thisBuild > otherBuild;
  }
}
