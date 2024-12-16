import 'package:http/http.dart' as http;

import '../../domain/entity/version.dart';
import '../../domain/repo/version_retriever.dart';
import '../github.dart';

VersionRetriever getRemoteVersion = () async {
  final client = http.Client();
  try {
    final request = http.Request('GET', Uri.parse(kRepoReleases))
      ..followRedirects = false;
    final response = await client.send(request);
    final location = response.headers['location'];
    final lastSlash = location!.lastIndexOf('tag/v');
    return Version.parse(location.substring(lastSlash + 5, location.length));
  } finally {
    client.close();
  }
};
