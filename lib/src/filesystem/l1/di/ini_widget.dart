import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/ini.dart';
import '../impl/ini_file_repo.dart';
import 'watcher.dart';

part 'ini_widget.g.dart';

@riverpod
class IniRepo extends _$IniRepo {
  late final IniFileRepoImpl _repo;

  @override
  Stream<List<IniStatement>> build(final IniFile iniFile) {
    final watcher = ref.watch(fileWatchProvider(iniFile.path));
    final repo = _repo = IniFileRepoImpl(watcher: watcher, iniFile: iniFile);
    ref.onDispose(repo.dispose);
    return repo.statements;
  }

  Future<void> edit({
    required final int lineNum,
    required final String value,
  }) async {
    await _repo.edit(lineNum: lineNum, value: value);
  }
}
