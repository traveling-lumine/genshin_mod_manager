import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/transformers.dart';
import 'package:win32/win32.dart';

import '../../../app_config/l0/entity/game_config.dart';
import '../../l0/api/filesystem.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/folder_move_result.dart';
import '../../l0/entity/ini.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../../l0/entity/mod_toggle_result.dart';
import 'watcher.dart';

const _disabledHeader = 'DISABLED';
const _kShaderFixes = 'ShaderFixes';
const _previewExtensions = [
  '.png',
  '.jpg',
  '.jpeg',
  '.gif',
  '.webp',
  '.bmp',
  '.avif',
  '.wbmp',
];
Archive _collapseArchiveFolder(final Archive archive) {
  final longestCommonPrefix1 = _longestCommonPrefix(archive);
  final longestCommonLen =
      longestCommonPrefix1.lastIndexOf(RegExp(r'[/\\]')) + 1;
  if (longestCommonLen == 0) {
    return archive;
  }
  final newArchive = Archive();
  for (final entry in archive) {
    var name = entry.name.substring(longestCommonLen);
    if (name.isEmpty) {
      continue;
    }
    try {
      final decodeString = cp949.decodeString(name);
      if (name == cp949.encodeToString(decodeString)) {
        name = decodeString;
      }
    } on FormatException {
      // do nothing
    }
    entry.name = name;
    newArchive.add(entry);
  }
  return newArchive;
}

Future<Directory> _copyDirectory(
  final Directory dir,
  final String destPath,
) async {
  final listFuture = dir.list().toList();
  final newDir = Directory(destPath);
  await newDir.create(recursive: true);
  final list = await listFuture;
  final copyFutures = <Future<FileSystemEntity>>[];
  for (final entity in list) {
    final entityDestPath = p.join(destPath, p.basename(entity.path));
    if (entity is File) {
      copyFutures.add(entity.copy(entityDestPath));
    } else if (entity is Directory) {
      copyFutures.add(_copyDirectory(entity, entityDestPath));
    }
  }
  await Future.wait(copyFutures);
  return newDir;
}

Future<void> _copyShaders(
  final String targetPath,
  final List<String> shaderPaths,
) async {
  // check for existence first
  await _shaderFinder(
    targetPath,
    shaderPaths,
    (final found) => throw FileSystemException(
      'Target directory is not empty',
      p.basename(found),
    ),
  );
  final futures = <Future<File>>[];
  for (final elem in shaderPaths) {
    final modFilename = p.basename(elem);
    final moveName = p.join(
      targetPath,
      modFilename,
    );
    futures.add(File(elem).copy(moveName));
  }
  await Future.wait(futures);
}

Future<void> _deleteShaders(
  final String targetPath,
  final List<String> shaderPaths,
) async {
  await _shaderFinder(
    targetPath,
    shaderPaths,
    (final found) => Future(() => File(found).deleteSync()),
  );
}

Future<ModToggleResult> _disable({
  required final GameConfig gameConfig,
  required final String modPath,
}) async {
  if (!Directory(modPath).existsSync()) {
    return const ModToggleResult.modNotFound();
  }
  if (!modPath.pIsEnabled) {
    return const ModToggleResult.alreadyDisabled();
  }
  final renameTarget = modPath.pDisabledForm;
  if (Directory(renameTarget).existsSync()) {
    return ModToggleResult.modRenameClash(p.basename(renameTarget));
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }
  final modShaderPath = p.join(
    renameTarget,
    _kShaderFixes,
  );
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await _pathsUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
  final modExecFile = gameConfig.modExecFile;
  final shaderFixesPath = modExecFile != null
      ? p.join(
          p.dirname(modExecFile),
          _kShaderFixes,
        )
      : null;
  if (shaderFixesPath == null) {
    return const ModToggleResult.done();
  }
  try {
    await _deleteShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException {
    try {
      await _copyShaders(shaderFixesPath, shaderFilenames);
    } on FileSystemException {
      return const ModToggleResult.shaderCleanupFailed();
    }
    return const ModToggleResult.shaderDeleteFailed();
  }
  return const ModToggleResult.done();
}

Future<ModToggleResult> _enable({
  required final GameConfig gameConfig,
  required final String modPath,
}) async {
  if (!Directory(modPath).existsSync()) {
    return const ModToggleResult.modNotFound();
  }
  if (modPath.pIsEnabled) {
    return const ModToggleResult.alreadyEnabled();
  }
  final renameTarget = modPath.pEnabledForm;
  if (Directory(renameTarget).existsSync()) {
    return ModToggleResult.modRenameClash(p.basename(renameTarget));
  }
  try {
    await Directory(modPath).rename(renameTarget);
  } on PathAccessException {
    return const ModToggleResult.modRenameFailed();
  }
  final modShaderPath = p.join(
    renameTarget,
    _kShaderFixes,
  );
  final List<String> shaderFilenames;
  try {
    shaderFilenames = await _pathsUnder<File>(modShaderPath);
  } on PathNotFoundException {
    return const ModToggleResult.modHasNoShaders();
  }
  final modExecFile = gameConfig.modExecFile;
  final shaderFixesPath = modExecFile != null
      ? p.join(
          p.dirname(modExecFile),
          _kShaderFixes,
        )
      : null;
  if (shaderFixesPath == null) {
    return const ModToggleResult.done();
  }
  try {
    await _copyShaders(shaderFixesPath, shaderFilenames);
  } on FileSystemException {
    try {
      await _deleteShaders(shaderFixesPath, shaderFilenames);
    } on FileSystemException {
      return const ModToggleResult.shaderCleanupFailed();
    }
    return const ModToggleResult.shaderCopyFailed();
  }
  return const ModToggleResult.done();
}

Future<String?> _findPreviewPath(
  final String path, {
  final String name = 'preview',
}) async {
  final paths = await _pathsUnder<File>(path);
  for (final entityPath in paths) {
    final basename = p.basenameWithoutExtension(entityPath);
    if (!p.equals(basename, name)) {
      continue;
    }
    final ext = p.extension(entityPath);
    for (final previewExt in _previewExtensions) {
      if (p.equals(ext, previewExt)) {
        return entityPath;
      }
    }
  }
  return null;
}

Future<String> _getNonCollidingModName(
  final String categoryPath,
  final String name,
) async {
  final sanitizedName = _sanitizeString(name);
  final enabledFormDirNames = (await _pathsUnder<Directory>(categoryPath))
      .map((final e) => p.basename(e.pEnabledForm))
      .toSet();
  var counter = 0;
  var noCollisionDestDirName = sanitizedName.pEnabledForm;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '${sanitizedName.pEnabledForm} ($counter)';
  }
  return noCollisionDestDirName;
}

Future<ImportResult> _importDir(
  final ModCategory categoryPath,
  final String dropPath,
  final bool type,
) async {
  final newPath = p.join(
    categoryPath.path,
    p.basename(dropPath),
  );
  if (FileSystemEntity.isDirectorySync(newPath)) {
    return const ImportResult.destinationExists();
  }
  final sourceDir = Directory(dropPath);
  if (type) {
    await _moveDir(src: sourceDir, newPath: newPath);
  } else {
    await sourceDir.copyToPath(newPath);
  }
  return const ImportResult.done();
}

bool _isZip(final String dropPath) =>
    FileSystemEntity.isFileSync(dropPath) &&
    p.equals(p.extension(dropPath), '.zip');

String _longestCommonPrefix(final Archive archive) {
  final files = archive.files;
  if (files.isEmpty) {
    return '';
  }
  var s1 = files.first.name;
  var s2 = files.first.name;
  for (final ArchiveFile(name: fileName) in files) {
    if (fileName.compareTo(s1) < 0) {
      s1 = fileName;
    } else if (fileName.compareTo(s2) > 0) {
      s2 = fileName;
    }
  }
  final length = min(s1.length, s2.length);
  var i = 0;
  for (; i < length; i++) {
    if (s1.codeUnitAt(i) != s2.codeUnitAt(i)) {
      break;
    }
  }
  return s1.substring(0, i);
}

Future<void> _moveDir({
  required final Directory src,
  required final String newPath,
}) async {
  try {
    await src.rename(newPath);
  } on FileSystemException catch (e) {
    if (e.osError?.errorCode == ERROR_NOT_SAME_DEVICE) {
      await src.copyToPath(newPath);
      await src.delete(recursive: true);
    } else {
      rethrow;
    }
  }
}

Future<List<String>> _pathsUnder<T extends FileSystemEntity>(
  final String path,
) async {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return [];
  }
  final res =
      dir.list().whereType<T>().map((final event) => event.path).toList();
  return res;
}

String _sanitizeString(final String name) {
  final sanitizedName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  return sanitizedName.trim();
}

Future<void> _shaderFinder(
  final String targetPath,
  final List<String> shaderPaths,
  final Future<void> Function(String foundPath) onFound,
) async {
  final list = await _pathsUnder<File>(targetPath);
  final programShadersMap = {for (final e in list) p.basename(e): e};
  final shaderSets = shaderPaths.map(p.basename).toSet();
  final inter = programShadersMap.keys.toSet().intersection(shaderSets);
  final futures = inter.map((final elem) => onFound(programShadersMap[elem]!));
  await Future.wait(futures);
}

class FilesystemImpl implements Filesystem {
  var _isPaused = false;
  final Map<
      String,
      (
        StreamController<FileSystemEvent?>,
        StreamSubscription<FileSystemEvent>,
        int
      )> _watchStream = {};
  @override
  Future<ModToggleResult> disableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  }) =>
      _disable(
        gameConfig: gameConfig,
        modPath: p.join(
          gameConfig.modRoot!,
          categoryName,
          modName,
        ),
      );
  @override
  Future<ModToggleResult> disableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  }) =>
      _disable(gameConfig: gameConfig, modPath: mod.path);
  @override
  Future<ModToggleResult> disableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  }) =>
      _disable(
        gameConfig: gameConfig,
        modPath: p.join(
          category.path,
          modName,
        ),
      );
  @override
  Future<void> dispose() async {
    await Future.wait<Object?>(
      _watchStream.values
          .expand((final path) => [path.$2.cancel(), path.$1.close()]),
    );
  }

  @override
  Future<ModToggleResult> enableDirect({
    required final GameConfig gameConfig,
    required final String categoryName,
    required final String modName,
  }) =>
      _enable(
        gameConfig: gameConfig,
        modPath: p.join(
          gameConfig.modRoot!,
          categoryName,
          modName.pDisabledForm,
        ),
      );
  @override
  Future<ModToggleResult> enableMod({
    required final GameConfig gameConfig,
    required final Mod mod,
  }) =>
      _enable(gameConfig: gameConfig, modPath: mod.path);
  @override
  Future<ModToggleResult> enableOf({
    required final GameConfig gameConfig,
    required final ModCategory category,
    required final String modName,
  }) =>
      _enable(
        gameConfig: gameConfig,
        modPath: p.join(
          category.path,
          modName.pDisabledForm,
        ),
      );
  @override
  Stream<List<ModCategory>> getCategories(
    final Stream<FileSystemEvent?> stream,
    final String modRoot,
  ) =>
      stream.asyncMap(
        (final event) async => (await _pathsUnder<Directory>(modRoot))
            .map((final e) => ModCategory(path: e, name: p.basename(e)))
            .toList()
          ..sort((final a, final b) => compareNatural(a.name, b.name)),
      );
  @override
  Stream<String?> getFolderIconStream(
    final Stream<FileSystemEvent?> stream,
    final String path,
    final ModCategory category,
  ) =>
      stream.debounceTime(const Duration(milliseconds: 100)).asyncMap(
        (final event) async {
          final s = await _findPreviewPath(
            path,
            name: category.name,
          );
          return s;
        },
      );
  @override
  Stream<List<Mod>> getModsInCategory(
    final Stream<FileSystemEvent?> stream,
    final ModCategory category,
  ) =>
      stream
          .where((final event) => event is! FileSystemModifyEvent)
          .debounceTime(const Duration(milliseconds: 100))
          .asyncMap(
            (final _) async => (await _pathsUnder<Directory>(category.path))
                .map(
                  (final e) => Mod(
                    path: e,
                    displayName: p.basename(e.pEnabledForm),
                    isEnabled: e.pIsEnabled,
                    category: category,
                  ),
                )
                .toList(),
          );
  @override
  Future<List<String>> getSubDirNames({
    required final String path,
    final bool onlyEnabled = false,
  }) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return const [];
    }
    final map =
        dir.list().whereType<Directory>().map((final e) => p.basename(e.path));
    if (onlyEnabled) {
      return map.where((final e) => e.pIsEnabled).toList();
    }
    return map.toList();
  }

  @override
  Future<List<String>> getSubDirNamesOf({
    required final String path,
    required final String pJoin,
    final bool onlyEnabled = false,
  }) =>
      getSubDirNames(
        path: p.join(
          path,
          pJoin,
        ),
        onlyEnabled: onlyEnabled,
      );
  @override
  List<String> getUnavailableReasons(final GameConfig appState) {
    final modRoot = appState.modRoot;
    final migotoRoot = appState.modExecFile;
    final launcherRoot = appState.launcherFile;
    final execRoot = File(Platform.resolvedExecutable).parent.path;
    final reason = <String>[];
    if (modRoot != null && p.isWithin(execRoot, modRoot)) {
      reason.add('mods');
    }
    if (migotoRoot != null && p.isWithin(execRoot, migotoRoot)) {
      reason.add('3d migoto');
    }
    if (launcherRoot != null && p.isWithin(execRoot, launcherRoot)) {
      reason.add('launcher');
    }
    return reason;
  }

  @override
  Future<ImportResult> importPath({
    required final String targetPath,
    required final ModCategory category,
    required final bool moveDir,
  }) async {
    if (FileSystemEntity.isDirectorySync(targetPath)) {
      return _importDir(category, targetPath, moveDir);
    } else if (_isZip(targetPath)) {
      return _importZip(targetPath, category);
    } else {
      return const ImportResult.unknownType();
    }
  }

  @override
  Future<ImportResult> importZipFile(
    final ModCategory category,
    final String filePath,
    final Uint8List content,
  ) async {
    final destDirName = await _getNonCollidingModName(category.path, filePath);
    final destDirPath = p.join(
      category.path,
      destDirName,
    );
    final archive = _collapseArchiveFolder(ZipDecoder().decodeBytes(content));
    await extractArchiveToDisk(archive, destDirPath);
    return const ImportResult.done();
  }

  @override
  Stream<List<IniFile>> iniPathsStream(
    final Stream<FileSystemEvent?> stream,
    final Mod mod,
  ) =>
      stream.asyncMap(
        (final event) async => (await _pathsUnder<File>(mod.path))
            .where(
              (final e) => p.equals(p.extension(e), '.ini') && e.pIsEnabled,
            )
            .map(
              (final e) => IniFile(
                path: e,
                name: p.basename(e),
                mod: mod,
              ),
            )
            .toList(),
      );
  @override
  Stream<String?> modPreviewPathStream(
    final Stream<FileSystemEvent?> stream,
    final Mod mod,
  ) =>
      stream.asyncMap(
        (final event) async {
          final previewName = await _findPreviewPath(mod.path);
          return previewName;
        },
      );
  @override
  Future<void> moveModInto({
    required final ModCategory category,
    required final Mod mod,
  }) async {
    await _moveDir(
      src: Directory(mod.path),
      newPath: p.join(
        category.path,
        p.basename(mod.path),
      ),
    );
  }

  @override
  Future<void> pauseAllWatchers() async {
    if (_isPaused) {
      return;
    }
    _isPaused = true;
    await Future.wait(
      _watchStream.values.map((final stream) => stream.$2.cancel()),
    );
  }

  @override
  void resumeAllWatchers() {
    if (!_isPaused) {
      return;
    }
    _isPaused = false;
    for (final MapEntry(key: path, value: stream) in _watchStream.entries) {
      stream.$1.add(null); // send null to indicate that the stream is resumed
      if (Directory(path).existsSync()) {
        _watchStream[path] = (
          stream.$1,
          Directory(path).watch().listen(stream.$1.add),
          stream.$3
        );
      }
    }
  }

  @override
  Future<ProcessResult> runProcess(
    final String iniPath,
    final String? obtainValue,
  ) {
    final program = File(iniPath);
    final pwd = program.parent.path;
    final pName = p.basename(program.path);
    final arg = (obtainValue == null || obtainValue.isEmpty)
        ? [pName]
        : obtainValue
            .split(' ')
            .map((final e) => e == '%0' ? pName : e)
            .toList();
    return Process.run(
      'start',
      ['/b', '', ...arg],
      runInShell: true,
      workingDirectory: pwd,
    );
  }

  @override
  Watcher watchDirectory({
    required final String path,
  }) {
    if (!Directory(path).existsSync()) {
      final nullBehaviorSubject = StreamController<FileSystemEvent?>()
        ..add(null);
      return FSSubscription(
        stream: nullBehaviorSubject.stream,
        onCancel: nullBehaviorSubject.close,
      );
    }
    final controller = StreamController<FileSystemEvent?>()..add(null);
    final stream = _getSwitchStream(path);
    final subscription = stream.listen(controller.add);
    return FSSubscription(
      stream: controller.stream,
      onCancel: () async {
        await Future.wait([
          subscription.cancel(),
          controller.close(),
          _releaseSwitchStream(path),
        ]);
      },
    );
  }

  @override
  Watcher watchFile({
    required final String path,
  }) {
    final dirPath = File(path).parent.path;
    final controller = StreamController<FileSystemEvent?>()..add(null);
    final stream = _getSwitchStream(dirPath);
    final subscription = stream.listen((final event) {
      if (event == null) {
        controller.add(null);
        return;
      }
      if (event is FileSystemMoveEvent) {
        if (p.equals(event.destination ?? '', path)) {
          controller.add(event);
        }
      } else if (p.equals(event.path, path)) {
        controller.add(event);
      }
    });
    return FSSubscription(
      stream: controller.stream,
      onCancel: () async {
        await Future.wait([
          subscription.cancel(),
          controller.close(),
          _releaseSwitchStream(dirPath),
        ]);
      },
    );
  }

  @override
  Future<void> writeImage(final Mod mod, final Uint8List bytes) async {
    final filePath = p.join(
      mod.path,
      'preview.png',
    );
    await File(filePath).writeAsBytes(bytes);
  }

  Stream<FileSystemEvent?> _getSwitchStream(final String path) {
    final stream = _watchStream[path];
    if (stream != null) {
      _watchStream[path] = (stream.$1, stream.$2, stream.$3 + 1);
      return stream.$1.stream;
    }
    // these streams will be closed when the path is released
    // ignore: close_sinks
    final controller = StreamController<FileSystemEvent?>.broadcast();
    final streamForSubscription = _isPaused
        ? const Stream<FileSystemEvent>.empty()
        : Directory(path).watch();
    // see above
    // ignore: cancel_subscriptions
    final subscription = streamForSubscription.listen(controller.add);
    _watchStream[path] = (controller, subscription, 1);
    return controller.stream;
  }

  Future<ImportResult> _importZip(
    final String dropPath,
    final ModCategory categoryPath,
  ) async {
    final content = await File(dropPath).readAsBytes();
    return importZipFile(
      categoryPath,
      p.basenameWithoutExtension(dropPath),
      content,
    );
  }

  Future<void> _releaseSwitchStream(final String path) async {
    final stream = _watchStream[path];
    if (stream == null) {
      return;
    }
    if (stream.$3 == 1) {
      await Future.wait([stream.$2.cancel(), stream.$1.close()]);
      _watchStream.remove(path);
    } else {
      _watchStream[path] = (stream.$1, stream.$2, stream.$3 - 1);
    }
  }
}

extension _CopyDirectory on Directory {
  Future<void> copyToPath(final String dest) async {
    await _copyDirectory(this, dest);
  }
}

extension _PathOpString on String {
  String get pDisabledForm {
    var baseName = p.basename(this);
    if (baseName.pIsEnabled) {
      baseName = '$_disabledHeader ${baseName.trimLeft()}';
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  String get pEnabledForm {
    var baseName = p.basename(this);
    while (!baseName.pIsEnabled) {
      baseName = baseName.substring(_disabledHeader.length).trimLeft();
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return p.join(
        p.dirname(this),
        baseName,
      );
    }
  }

  bool get pIsEnabled =>
      !p.basename(this).toLowerCase().startsWith(_disabledHeader.toLowerCase());
}
