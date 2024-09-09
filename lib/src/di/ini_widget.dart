import 'dart:convert';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/structure/entity/ini.dart';
import 'fs_watcher.dart';

part 'ini_widget.g.dart';

@riverpod
class IniLines extends _$IniLines {
  @override
  List<String> build(final IniFile iniFile) {
    List<String> addData() => File(iniFile.path)
        .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true));

    final watcher = ref.watch(
      fileEventWatcherProvider(iniFile.path, detectModifications: true),
    );
    final subscription = watcher.listen((final event) {
      if (event is FileSystemModifyEvent) {
        state = addData();
      }
    });
    ref.onDispose(subscription.cancel);

    return addData();
  }

  void editIniFile(final IniSection section, final String value) {
    var metSection = false;
    final allLines = <String>[];
    final lineHeader = section.key;
    final path = File(section.iniFile.path);
    path.readAsLinesSync().forEach((final element) {
      final regExp = RegExp(r'\[Key.*?\]').firstMatch(element);
      if (regExp != null && regExp.group(0) == section.section) {
        metSection = true;
      }
      if (metSection && element.toLowerCase() == section.line.toLowerCase()) {
        allLines.add('$lineHeader = ${value.trim()}');
      } else {
        allLines.add(element);
      }
    });
    path.writeAsStringSync(allLines.join('\n'));
  }
}
