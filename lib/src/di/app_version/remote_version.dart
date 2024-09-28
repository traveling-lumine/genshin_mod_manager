import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/app_version/github.dart';

part 'remote_version.g.dart';

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
