import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/structure/entity/ini.dart';
import '../../backend/structure/usecase/ini_file.dart';
import '../fs_watcher.dart';

part 'ini_widget.g.dart';

@riverpod
class IniLines extends _$IniLines {
  @override
  List<IniStatement> build(final IniFile iniFile) {
    final watcher = ref.watch(
      fileEventWatcherProvider(iniFile.path, detectModifications: true),
    );
    final subscription = watcher.listen((final event) {
      if (event is FileSystemModifyEvent) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(subscription.cancel);

    return parseIniFileUseCase(iniFile);
  }

  void editIniFile(final int lineNum, final String value) =>
      editIniFileUseCase(iniFile, lineNum, value);
}
