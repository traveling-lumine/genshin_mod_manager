import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/github.dart';

part 'app_version.g.dart';

@riverpod
Future<String> versionString(final VersionStringRef ref) async {
  final info = await PackageInfo.fromPlatform();
  final version = info.version;
  final buildNumber = info.buildNumber;
  if (buildNumber.isEmpty) {
    return version;
  }
  return '$version+$buildNumber';
}

@riverpod
Future<String?> remoteVersion(final RemoteVersionRef ref) async {
  final url = Uri.parse(kRepoReleases);
  final client = http.Client();
  final request = http.Request('GET', url)..followRedirects = false;
  final upstreamVersion = client.send(request).then((final value) {
    final location = value.headers['location'];
    if (location == null) {
      return null;
    }
    final lastSlash = location.lastIndexOf('tag/v');
    if (lastSlash == -1) {
      return null;
    }
    return location.substring(lastSlash + 5, location.length);
  });
  return upstreamVersion;
}

@riverpod
Future<bool> isOutdated(final IsOutdatedRef ref) async {
  final localFuture = ref.watch(versionStringProvider.future);
  final remoteFuture = ref.watch(remoteVersionProvider.future);
  final awaited = await Future.wait([localFuture, remoteFuture]);
  final local = awaited[0];
  final remote = awaited[1];
  if (local == null || remote == null) {
    return false;
  }
  return _isFirstVersionOutdated(local, remote);
}

bool _isFirstVersionOutdated(final String local, final String remote) {
  // Split the version strings into parts
  final currentParts = local.split('+');
  final newParts = remote.split('+');

  // Split version and build parts
  final currentVersionParts = currentParts[0].split('.');
  final newVersionParts = newParts[0].split('.');

  // Compare version numbers
  for (var i = 0; i < currentVersionParts.length; i++) {
    final current = int.parse(currentVersionParts[i]);
    final updated = int.parse(newVersionParts[i]);

    if (current < updated) {
      return true; // The current version is outdated
    } else if (current > updated) {
      return false; // The current version is newer
    }
  }

  // If one version has a build number and the other does not,
  // prioritize the one with the build number
  if (currentParts.length != newParts.length) {
    return currentParts.length < newParts.length;
  }

  // Compare build numbers if available
  if (currentParts.length > 1 && newParts.length > 1) {
    final currentBuild = int.parse(currentParts[1]);
    final newBuild = int.parse(newParts[1]);

    if (currentBuild < newBuild) {
      return true; // The current version is outdated
    } else if (currentBuild > newBuild) {
      return false; // The current version is newer
    }
  }

  // If versions are equal, not outdated
  return false;
}
