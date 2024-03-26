import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ini_widget.g.dart';

class IniModel {
  IniModel(this._iniFile) {
    final dir = Directory(_iniFile.path.pDirname);
    _iniLinesController.add(
      File(_iniFile.path)
          .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true)),
    );
    _subscription = dir
        .watch(events: FileSystemEvent.modify)
        .where((final event) => event.path.pEquals(_iniFile.path))
        .listen(_listen);
  }

  final IniFile _iniFile;
  late final StreamSubscription<FileSystemEvent> _subscription;

  Stream<List<String>> get iniLines => _iniLinesController.stream;
  final _iniLinesController = StreamController<List<String>>();

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_iniLinesController.close());
  }

  void _listen(final FileSystemEvent event) {
    _iniLinesController.add(
      File(_iniFile.path)
          .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true)),
    );
  }
}

@riverpod
class IniLines extends _$IniLines {
  @override
  Stream<List<String>> build(final IniFile iniFile) {
    final model = IniModel(iniFile);
    ref.onDispose(model.dispose);
    return model.iniLines;
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
