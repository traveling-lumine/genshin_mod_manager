import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class IniWidgetViewModel implements BaseViewModel {
  Future<List<String>>? get iniLines;

  void editIniFile(final IniSection section, final String value);
}

IniWidgetViewModel createIniWidgetViewModel({
  required final IniFile iniFile,
  required final RecursiveFileSystemWatcher watcher,
}) =>
    _IniWidgetViewModelImpl(
      iniFile: iniFile,
      watcher: createFileWatcher(path: iniFile.path, watcher: watcher),
    );

class _IniWidgetViewModelImpl extends ChangeNotifier
    implements IniWidgetViewModel {
  _IniWidgetViewModelImpl({required this.watcher, required this.iniFile}) {
    _subscription = watcher.updateCode.stream.listen(_listen);
  }

  late final StreamSubscription<int> _subscription;
  final FileWatcher watcher;
  final IniFile iniFile;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Future<List<String>>? iniLines;

  @override
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

  void _listen(final event) {
    // ignore: discarded_futures
    iniLines = _getFuture();
    notifyListeners();
  }

  Future<List<String>> _getFuture() => Future(
        () => File(iniFile.path)
            .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true)),
      );
}
