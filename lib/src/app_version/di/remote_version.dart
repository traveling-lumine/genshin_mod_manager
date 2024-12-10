import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entity/version.dart';
import '../github.dart';

part 'remote_version.g.dart';

@riverpod
Future<Version?> remoteVersion(final RemoteVersionRef ref) async {
  final client = http.Client();
  try {
    return _getLatestVersion(client);
  } finally {
    client.close();
  }
}

Future<Version?> _getLatestVersion(final http.Client client) async {
  final request = http.Request('GET', Uri.parse(kRepoReleases))
    ..followRedirects = false;
  final send = await client.send(request);
  final location = send.headers['location'];
  if (location == null) {
    return null;
  }
  final lastSlash = location.lastIndexOf('tag/v');
  if (lastSlash == -1) {
    return null;
  }
  return Version.parse(location.substring(lastSlash + 5, location.length));
}
