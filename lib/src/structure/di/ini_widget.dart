import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../fs_interface/di/fs_watcher.dart';
import '../entity/ini.dart';
import '../usecase/ini_file.dart';

part 'ini_widget.g.dart';

@riverpod
class IniLines extends _$IniLines {
  @override
  List<IniStatement> build(final IniFile iniFile) {
    final watcher = ref.watch(
      fileEventWatcherProvider(iniFile.path, detectModifications: true),
    );
    final subscription = watcher.listen((final event) => ref.invalidateSelf());
    ref.onDispose(subscription.cancel);

    return parseIniFileUseCase(iniFile);
  }

  void editIniFile(final int lineNum, final String value) =>
      editIniFileUseCase(iniFile, lineNum, value);
}
