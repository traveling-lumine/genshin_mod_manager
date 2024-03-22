import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mod_card_vm.g.dart';

class ModCardModel {
  ModCardModel(this._mod) {
    final modDir = Directory(_mod.path);
    _updatePaths(getUnderSync<File>(_mod.path));
    _subscription = modDir.watch().listen(_listen);
  }

  final Mod _mod;
  late final StreamSubscription<FileSystemEvent> _subscription;

  Stream<String?> get configPath => _configPathController.stream;
  final _configPathController = StreamController<String?>();
  String? configPathCurVal;

  void setConfigPath(final String? val) {
    if (configPathCurVal != val) {
      configPathCurVal = val;
      _configPathController.add(val);
    }
  }

  Stream<FileImage?> get preview => _previewController.stream;
  final _previewController = StreamController<FileImage?>();
  FileImage? previewCurVal;

  void setPreview(final FileImage? val) {
    if (previewCurVal != val) {
      previewCurVal = val;
      _previewController.add(val);
    }
  }

  Stream<List<String>> get iniPaths => _iniPathsController.stream;
  final _iniPathsController = StreamController<List<String>>();
  late List<String> iniPathsCurVal;

  void setIniPaths(final List<String> val) {
    if (!const ListEquality().equals(iniPathsCurVal, val)) {
      iniPathsCurVal = val;
      _iniPathsController.add(val);
    }
  }

  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_configPathController.close());
    unawaited(_previewController.close());
    unawaited(_iniPathsController.close());
  }

  void _listen(final FileSystemEvent event) {
    final path = event.path;
    switch (event) {
      case FileSystemModifyEvent _:
        _onModify(path);
      case FileSystemCreateEvent _:
        _onCreate(path);
      case FileSystemDeleteEvent _:
        _onDelete(path);
      case FileSystemMoveEvent _:
        _onMove(path, event.destination);
    }
  }

  void _onModify(final String path) {
    final fileImage = previewCurVal;
    if (fileImage == null) {
      return;
    }
    if (fileImage.file.path.pEquals(path)) {
      unawaited(() async {
        await fileImage.evict();
        setPreview(FileImage(File(path)));
      }());
    }
  }

  void _onCreate(final String path) {
    if (path.pBasename.pEquals(kAkashaConfigFilename)) {
      setConfigPath(path);
    }
    if (previewCurVal == null) {
      final previewPath = findPreviewFileInString([path]);
      if (previewPath != null) {
        unawaited(() async {
          final fileImage = FileImage(File(previewPath));
          await fileImage.evict();
          setPreview(fileImage);
        }());
      }
    }
    if (path.pExtension.pEquals('.ini')) {
      setIniPaths([...iniPathsCurVal, path]);
    }
  }

  void _onDelete(final String path) {
    if (configPathCurVal?.pEquals(path) ?? false) {
      setConfigPath(null);
    }
    if (previewCurVal?.file.path.pEquals(path) ?? false) {
      unawaited(() async {
        await previewCurVal?.evict();
        setPreview(null);
      }());
    }
    final iniPaths = iniPathsCurVal;
    if (iniPaths.remove(path)) {
      setIniPaths([...iniPaths]);
    }
  }

  void _onMove(final String path, final String? destination) {
    if (destination == null) {
      _updatePaths(
        Directory(_mod.path).listSync().map((final e) => e.path).toList(),
      );
    } else {
      _onDelete(path);
      _onCreate(destination);
      _onModify(destination);
    }
  }

  void _updatePaths(final List<String> paths) {
    setConfigPath(
      paths.firstWhereOrNull(
        (final path) => path.pBasename.pEquals(kAkashaConfigFilename),
      ),
    );

    final previewPath = findPreviewFileInString(paths);
    if (previewPath != null) {
      unawaited(() async {
        final fileImage = FileImage(File(previewPath));
        await fileImage.evict();
        setPreview(fileImage);
      }());
    }

    setIniPaths(
      paths.where((final path) => path.pExtension.pEquals('.ini')).toList(),
    );
  }
}

@riverpod
ModCardModel modCardModel(final ModCardModelRef ref, final Mod mod) {
  final modCardModel = ModCardModel(mod);
  ref.onDispose(modCardModel.dispose);
  return modCardModel;
}

@riverpod
Stream<String?> configPath(final ConfigPathRef ref, final Mod mod) {
  final model = ref.watch(modCardModelProvider(mod));
  return model.configPath;
}

@riverpod
Stream<FileImage?> preview(final PreviewRef ref, final Mod mod) {
  final model = ref.watch(modCardModelProvider(mod));
  return model.preview;
}

@riverpod
Stream<List<String>> iniPaths(final IniPathsRef ref, final Mod mod) {
  final model = ref.watch(modCardModelProvider(mod));
  return model.iniPaths;
}
