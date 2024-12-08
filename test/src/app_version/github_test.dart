import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/github.dart';

import 'package:http/http.dart' as http;

void main() {
  test('Test valid base link', () async {
    const link = kRepoBase;
    await expectStatus200(link);
  });
  test('Test valid releases link', () async {
    const link = kRepoReleases;
    await expectStatus200(link);
  });
}

Future<void> expectStatus200(final String link) async {
  final uri = Uri.parse(link);
  final response = await http.get(uri);
  expect(response.statusCode, 200);
}
