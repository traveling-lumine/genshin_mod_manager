import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'current_version.dart';
import 'remote_version.dart';

part 'is_outdated.g.dart';

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
