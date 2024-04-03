import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version.g.dart';

const _kRepoReleases = '$kRepoBase/releases/latest';

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
  final url = Uri.parse(_kRepoReleases);
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
  if (remote == null) {
    return false;
  }
  return local != remote;
}
