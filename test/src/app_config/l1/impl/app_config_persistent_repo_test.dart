import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_config/l1/entity/app_config.dart';
import 'package:genshin_mod_manager/src/app_config/l1/entity/entry_helpers.dart';
import 'package:genshin_mod_manager/src/app_config/l1/impl/app_config_persistent_repo.dart';

void main() {
  late Directory curDir;
  late Directory tempDir;
  late File settingsFile;
  setUp(() {
    curDir = Directory.current;
    tempDir = Directory.current.createTempSync();
    Directory.current = tempDir;
    settingsFile = File('settings.json')..createSync();
  });
  tearDown(() {
    Directory.current = curDir;
    tempDir.deleteSync(recursive: true);
  });
  test('setting stream', () async {
    await settingsFile.writeAsString('''
{
"key": "value"
}''');
    final a = AppConfigPersistentRepoImpl();
    await expectLater(
      a.stream,
      emitsInOrder([
        <String, dynamic>{'key': 'value'},
      ]),
    );

    await a.dispose();
  });
  test('add entry', () async {
    final a = AppConfigPersistentRepoImpl();
    final entry = stringEntry(key: 'key', defaultValue: 'value');
    await a.save(AppConfig({'key': entry.defaultValue}));
    await expectLater(
      a.stream,
      emitsInOrder([
        <String, dynamic>{'key': 'value'},
      ]),
    );
    await a.dispose();
  });
}
