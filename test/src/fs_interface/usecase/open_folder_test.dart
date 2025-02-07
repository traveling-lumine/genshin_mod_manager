import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/filesystem/l0/usecase/open_folder.dart';

void main() {
  test('Opening a folder works', () async {
    final process = await openFolderUseCase('.');
    expect(process, isNotNull);
    process.kill();
  });
}
