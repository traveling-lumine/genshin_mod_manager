import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class ModCardViewModel implements BaseViewModel {
  String? get configPath;

  Future<FileImage>? get preview;

  List<String>? get iniPaths;

  void forceUpdate();
}

ModCardViewModel createModCardViewModel({required final Mod mod}) =>
    _ModCardViewModelImpl(mod: mod);

class _ModCardViewModelImpl extends ChangeNotifier implements ModCardViewModel {
  _ModCardViewModelImpl({required this.mod}) {
    final modDir = Directory(mod.path);
    _updatePaths(modDir.listSync().map((final e) => e.path).toList());
    _subscription = modDir.watch().listen(_listen);
  }

  late final StreamSubscription<FileSystemEvent> _subscription;
  final Mod mod;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  String? configPath;

  @override
  Future<FileImage>? preview;
  String? previewPath;

  @override
  List<String>? iniPaths;

  @override
  void forceUpdate() {
    final modDir = Directory(mod.path);
    _updatePaths(modDir.listSync().map((final e) => e.path).toList());
    notifyListeners();
  }

  void _listen(final FileSystemEvent event) {
    final path = event.path;
    final shouldNotify = switch (event) {
      (FileSystemModifyEvent _) => _onModify(path),
      (FileSystemCreateEvent _) => _onCreate(path),
      (FileSystemDeleteEvent _) => _onDelete(path),
      (FileSystemMoveEvent _) => _onMove(path, event.destination),
    };
    if (shouldNotify) {
      notifyListeners();
    }
  }

  bool _onModify(final String path) {
    var shouldNotify = false;
    if (previewPath?.pEquals(path) ?? false) {
      preview = Future(() async {
        final fileImage = FileImage(File(previewPath!));
        await fileImage.evict();
        return fileImage;
      });
      shouldNotify = true;
    }
    return shouldNotify;
  }

  bool _onCreate(final String path) {
    var shouldNotify = false;
    if (path.pBasename.pEquals(kAkashaConfigFilename)) {
      configPath = path;
      shouldNotify = true;
    }
    if (preview == null) {
      final previewPath = findPreviewFileInString([path]);
      if (previewPath != null) {
        preview = Future(() async {
          final fileImage = FileImage(File(previewPath));
          await fileImage.evict();
          return fileImage;
        });
        this.previewPath = previewPath;
        shouldNotify = true;
      }
    }
    if (path.pExtension.pEquals('.ini')) {
      iniPaths = [...?iniPaths, path];
      shouldNotify = true;
    }
    return shouldNotify;
  }

  bool _onDelete(final String path) {
    var shouldNotify = false;
    if (configPath?.pEquals(path) ?? false) {
      configPath = null;
      shouldNotify = true;
    }
    if (previewPath?.pEquals(path) ?? false) {
      unawaited(FileImage(File(previewPath!)).evict());
      preview = null;
      previewPath = null;
      shouldNotify = true;
    }
    if (iniPaths?.remove(path) ?? false) {
      iniPaths = [...iniPaths!];
      shouldNotify = true;
    }
    return shouldNotify;
  }

  bool _onMove(final String path, final String? destination) {
    var shouldNotify = false;
    if (destination == null) {
      _updatePaths(
        Directory(mod.path).listSync().map((final e) => e.path).toList(),
      );
      shouldNotify = true;
    } else {
      shouldNotify |= _onDelete(path);
      shouldNotify |= _onCreate(destination);
      shouldNotify |= _onModify(destination);
    }
    return shouldNotify;
  }

  void _updatePaths(final List<String> paths) {
    configPath = paths.firstWhereOrNull(
      (final path) => path.pBasename.pEquals(kAkashaConfigFilename),
    );

    final previewPath = findPreviewFileInString(paths);
    if (previewPath != null) {
      final fileImage = FileImage(File(previewPath));
      unawaited(fileImage.evict());
      preview = SynchronousFuture(fileImage);
      this.previewPath = previewPath;
    }

    iniPaths =
        paths.where((final path) => path.pExtension.pEquals('.ini')).toList();
  }
}
