import 'dart:async';
import 'dart:io';
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

const kShaderFixes = 'ShaderFixes';
const _disabledHeader = 'DISABLED';
const int _disabledHeaderLength = _disabledHeader.length;
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
Archive collapseArchiveFolder(final Archive archive) {
  final longestCommonPrefix1 =
      longestCommonPrefix(archive.files.map((final e) => e.name).toList());
  final int longestCommonLen;
  if (longestCommonPrefix1.endsWith('/') ||
      longestCommonPrefix1.endsWith(r'\')) {
    longestCommonLen = longestCommonPrefix1.length;
  } else {
    longestCommonLen = 0;
  }
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

/// In the [paths] list, find a file path that has a [name],
/// ignoring extensions.
String? findPreviewFileInString(
  final List<String> paths, {
  final String name = 'preview',
}) {
  for (final element in paths) {
    final filename = element.pBNameWoExt;
    if (!filename.pEquals(name)) {
      continue;
    }
    final ext = element.pExtension;
    for (final previewExt in _previewExtensions) {
      if (ext.pEquals(previewExt)) {
        return element;
      }
    }
  }
  return null;
}

Future<String> getNonCollidingModName(
  final String categoryPath,
  final String name,
) {
  final sanitizedName = sanitizeString(name);
  return getNonCollidingName(categoryPath, sanitizedName.pEnabledForm);
}

Future<String> getNonCollidingName(
  final String categoryPath,
  final String destDirName,
) async {
  final enabledFormDirNames = getUnderSync<Directory>(categoryPath)
      .map((final e) => e.pEnabledForm.pBasename)
      .toSet();
  var counter = 0;
  var noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  return noCollisionDestDirName;
}

Future<List<String>> getUnder<T extends FileSystemEntity>(
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

List<String> getUnderSync<T extends FileSystemEntity>(final String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    return [];
  }
  final res =
      dir.listSync().whereType<T>().map((final event) => event.path).toList();
  return res;
}

String longestCommonPrefix(final List<String> strings) {
  if (strings.isEmpty) {
    return '';
  }
  var s1 = strings.first;
  var s2 = strings.first;
  for (final s in strings) {
    if (s.compareTo(s1) < 0) {
      s1 = s;
    } else if (s.compareTo(s2) > 0) {
      s2 = s;
    }
  }
  final length = s1.length;
  var i = 0;
  for (; i < length; i++) {
    if (s1.codeUnitAt(i) != s2.codeUnitAt(i)) {
      break;
    }
  }
  return s1.substring(0, i);
}

String sanitizeString(final String name) {
  final sanitizedName = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  return sanitizedName.trim();
}

void _copyDirectorySync(final Directory dir, final String dest) {
  final listSync = dir.listSync();
  final newDir = Directory(dest)..createSync(recursive: true);
  for (final element in listSync) {
    final newName = newDir.path.pJoin(element.path.pBasename);
    if (element is File) {
      element.copySync(newName);
    } else if (element is Directory) {
      _copyDirectorySync(element, newName);
    }
  }
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
      found.pBasename,
    ),
  );
  final futures = <Future<File>>[];
  for (final elem in shaderPaths) {
    final modFilename = elem.pBasename;
    final moveName = targetPath.pJoin(modFilename);
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

Future<ImportResult> _importDir(
  final String categoryPath,
  final String dropPath,
  final bool type,
) async {
  final newPath = categoryPath.pJoin(dropPath.pBasename);
  if (FileSystemEntity.isDirectorySync(newPath)) {
    return const ImportResult.destinationExists();
  }
  final sourceDir = Directory(dropPath);
  if (type) {
    try {
      await sourceDir.rename(newPath);
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == ERROR_NOT_SAME_DEVICE) {
        sourceDir.copyToPath(newPath);
        await sourceDir.delete(recursive: true);
      } else {
        rethrow;
      }
    }
  } else {
    sourceDir.copyToPath(newPath);
  }
  return const ImportResult.done();
}

bool _isZip(final String dropPath) =>
    FileSystemEntity.isFileSync(dropPath) &&
    dropPath.pExtension.pEquals('.zip');
Future<void> _shaderFinder(
  final String targetPath,
  final List<String> shaderPaths,
  final Future<void> Function(String foundPath) onFound,
) async {
  final programShadersMap = Map<String, String>.fromEntries(
    getUnderSync<File>(targetPath).map((final e) => MapEntry(e.pBasename, e)),
  );
  final shaderSets = shaderPaths.map((final e) => e.pBasename).toSet();
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
  Future<ModToggleResult> disable({
    required final GameConfig currentGameConfig2,
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
      return ModToggleResult.modRenameClash(renameTarget.pBasename);
    }
    try {
      await Directory(modPath).rename(renameTarget);
    } on PathAccessException {
      return const ModToggleResult.modRenameFailed();
    }
    final modShaderPath = renameTarget.pJoin(kShaderFixes);
    final List<String> shaderFilenames;
    try {
      shaderFilenames = await getUnder<File>(modShaderPath);
    } on PathNotFoundException {
      return const ModToggleResult.modHasNoShaders();
    }
    final shaderFixesPath =
        currentGameConfig2.modExecFile?.pDirname.pJoin(kShaderFixes);
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

  @override
  Future<ModToggleResult> disableDirect({
    required final GameConfig currentGameConfig2,
    required final String modRootPath,
    required final String categoryName,
    required final String modName,
  }) =>
      disable(
        currentGameConfig2: currentGameConfig2,
        modPath: modRootPath.pJoin(categoryName, modName),
      );

  @override
  Future<ModToggleResult> disableOf({
    required final GameConfig currentGameConfig2,
    required final ModCategory category,
    required final String modName,
  }) =>
      disable(
        currentGameConfig2: currentGameConfig2,
        modPath: category.path.pJoin(modName),
      );

  @override
  Future<void> dispose() async {
    await Future.wait<Object?>(
      _watchStream.values
          .expand((final path) => [path.$2.cancel(), path.$1.close()]),
    );
  }

  @override
  Future<ModToggleResult> enable({
    required final GameConfig currentGameConfig2,
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
      return ModToggleResult.modRenameClash(renameTarget.pBasename);
    }
    try {
      await Directory(modPath).rename(renameTarget);
    } on PathAccessException {
      return const ModToggleResult.modRenameFailed();
    }
    final modShaderPath = renameTarget.pJoin(kShaderFixes);
    final List<String> shaderFilenames;
    try {
      shaderFilenames = await getUnder<File>(modShaderPath);
    } on PathNotFoundException {
      return const ModToggleResult.modHasNoShaders();
    }
    final shaderFixesPath =
        currentGameConfig2.modExecFile?.pDirname.pJoin(kShaderFixes);
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

  @override
  Future<ModToggleResult> enableDirect({
    required final GameConfig currentGameConfig2,
    required final String modRootPath,
    required final String categoryName,
    required final String modName,
  }) =>
      enable(
        currentGameConfig2: currentGameConfig2,
        modPath: modRootPath.pJoin(categoryName, modName.pDisabledForm),
      );

  @override
  Future<ModToggleResult> enableOf({
    required final GameConfig currentGameConfig2,
    required final ModCategory category,
    required final String modName,
  }) =>
      enable(
        currentGameConfig2: currentGameConfig2,
        modPath: category.path.pJoin(modName.pDisabledForm),
      );

  @override
  Stream<List<ModCategory>> getCategories(
    final Stream<FileSystemEvent?> stream,
    final String modRoot,
  ) =>
      stream.asyncMap(
        (final event) async => (await getUnder<Directory>(modRoot))
            .map((final e) => ModCategory(path: e, name: e.pBasename))
            .toList()
            .sortNatural(by: (final e) => e.name),
      );

  @override
  Stream<String?> getFolderIconStream(
    final Stream<FileSystemEvent?> stream,
    final String path,
    final ModCategory category,
  ) =>
      stream.debounceTime(const Duration(milliseconds: 100)).asyncMap(
            (final event) async => findPreviewFileInString(
              await getUnder<File>(path),
              name: category.name,
            ),
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
            (final _) async => (await getUnder<Directory>(category.path))
                .map(
                  (final e) => Mod(
                    path: e,
                    displayName: e.pEnabledForm.pBasename,
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
        dir.list().whereType<Directory>().map((final e) => e.path.pBasename);
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
        path: path.pJoin(pJoin),
        onlyEnabled: onlyEnabled,
      );

  @override
  List<String> getUnavailableReasons(final GameConfig appState) {
    final modRoot = appState.modRoot;
    final migotoRoot = appState.modExecFile;
    final launcherRoot = appState.launcherFile;
    final execRoot = File(Platform.resolvedExecutable).parent.path;

    final reason = <String>[];
    if (modRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('mods');
    }
    if (migotoRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('3d migoto');
    }
    if (launcherRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('launcher');
    }
    return reason;
  }

  @override
  Future<ImportResult> importPath({
    required final String dropPath,
    required final String categoryPath,
    required final bool moveDir,
  }) async {
    if (FileSystemEntity.isDirectorySync(dropPath)) {
      return _importDir(categoryPath, dropPath, moveDir);
    } else if (_isZip(dropPath)) {
      return _importZip(dropPath, categoryPath);
    } else {
      return const ImportResult.unknownType();
    }
  }

  @override
  Future<ImportResult> importZipFile(
    final String categoryPath,
    final String dropPath,
    final Uint8List content,
  ) async {
    final destDirName = await getNonCollidingModName(categoryPath, dropPath);
    final destDirPath = categoryPath.pJoin(destDirName);
    final archive = collapseArchiveFolder(ZipDecoder().decodeBytes(content));
    await extractArchiveToDisk(archive, destDirPath);
    return const ImportResult.done();
  }

  @override
  Stream<List<IniFile>> iniPathsStream(
    final Stream<FileSystemEvent?> stream,
    final Mod mod,
  ) =>
      stream.asyncMap(
        (final event) async => (await getUnder<File>(mod.path))
            .where((final e) => e.pExtension.pEquals('.ini') && e.pIsEnabled)
            .map(
              (final e) => IniFile(
                path: e,
                name: e.pBasename,
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
        (final event) async =>
            findPreviewFileInString(await getUnder<File>(mod.path)),
      );

  @override
  void moveDir(final Directory sourceDir, final String newPath) {
    try {
      sourceDir.renameSync(newPath);
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == ERROR_NOT_SAME_DEVICE) {
        // Moving across different drives
        sourceDir
          ..copyToPath(newPath)
          ..deleteSync(recursive: true);
      } else {
        rethrow;
      }
    }
  }

  @override
  void moveDirOf({
    required final Directory sourceDir,
    required final ModCategory category,
    required final Mod mod,
  }) {
    final newPath = category.path.pJoin(mod.path.pBasename);
    try {
      sourceDir.renameSync(newPath);
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == ERROR_NOT_SAME_DEVICE) {
        // Moving across different drives
        sourceDir
          ..copyToPath(newPath)
          ..deleteSync(recursive: true);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> newMethod(final Mod mod, final Uint8List bytes) async {
    final filePath = mod.path.pJoin('preview.png');
    await File(filePath).writeAsBytes(bytes);
  }

  @override
  Future<ProcessResult> newMethod2(
    final String iniPath,
    final String? obtainValue,
  ) {
    final program = File(iniPath);
    final pwd = program.parent.path;
    final pName = program.path.pBasename;
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
    final String categoryPath,
  ) {
    final content = File(dropPath).readAsBytesSync();
    return importZipFile(categoryPath, dropPath.pBNameWoExt, content);
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

/// Exception thrown when a mod zip extraction fails.
class ModZipExtractionException implements Exception {
  /// Default constructor.
  const ModZipExtractionException({required this.data});

  /// The data that failed to extract.
  final Uint8List data;
}

extension _CopyDirectory on Directory {
  /// Copy this directory to the given path.
  void copyToPath(final String dest) {
    _copyDirectorySync(this, dest);
  }
}

/// Extension on [String] to provide path operations.
extension _PathOpString on String {
  /// Returns the last part of the path.
  String get pBasename => p.basename(this);

  /// Returns the file name without extension.
  String get pBNameWoExt => p.basenameWithoutExtension(this);

  /// Returns the directory part of the path.
  String get pDirname => p.dirname(this);

  /// Returns the path in disabled form.
  String get pDisabledForm {
    var baseName = pBasename;
    if (baseName.pIsEnabled) {
      baseName = '$_disabledHeader ${baseName.trimLeft()}';
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return pDirname.pJoin(baseName);
    }
  }

  /// Returns the path in enabled form.
  String get pEnabledForm {
    var baseName = pBasename;
    while (!baseName.pIsEnabled) {
      baseName = baseName.substring(_disabledHeaderLength).trimLeft();
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return pDirname.pJoin(baseName);
    }
  }

  /// Returns the extension part of the path.
  String get pExtension => p.extension(this);

  /// Returns whether the path is enabled.
  bool get pIsEnabled =>
      !pBasename.toLowerCase().startsWith(_disabledHeader.toLowerCase());

  /// Returns whether the paths are equal.
  bool pEquals(final String other) => p.equals(this, other);

  /// Check whether this path is contained in [other].
  bool pIsWithin(final String other) => p.isWithin(other, this);

  /// Join the path with the given parts.
  String pJoin(
    final String part2, [
    final String? part3,
    final String? part4,
    final String? part5,
    final String? part6,
    final String? part7,
    final String? part8,
    final String? part9,
    final String? part10,
    final String? part11,
    final String? part12,
    final String? part13,
    final String? part14,
    final String? part15,
    final String? part16,
  ]) =>
      p.join(
        this,
        part2,
        part3,
        part4,
        part5,
        part6,
        part7,
        part8,
        part9,
        part10,
        part11,
        part12,
        part13,
        part14,
        part15,
        part16,
      );
}

extension _SortNatural<T> on List<T> {
  List<T> sortNatural({required final String Function(T) by}) =>
      this..sort((final a, final b) => compareNatural(by(a), by(b)));
}
