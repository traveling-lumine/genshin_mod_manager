import 'dart:io';

import 'package:path/path.dart' as p;

extension PathFSE on FileSystemEntity {
  PathString get pathString => PathString(path);

  PathString get basename => pathString.basename;

  PathString get basenameWithoutExtension =>
      pathString.basenameWithoutExtension;

  PathString get extension => pathString.extension;

  PathString join(PathString str) => pathString.join(str);
}

extension PathF on File {
  File copySyncPath(PathString dest) => copySync(dest.asString);
}

extension PathD on Directory {
  Directory renameSyncPath(PathString dest) => renameSync(dest.asString);
}

class PathString {
  final String _path;

  String get asString => _path;

  const PathString(this._path);

  Directory get toDirectory => Directory(asString);

  File get toFile => File(asString);

  PathString get dirname => PathString(p.dirname(asString));

  PathString get basename => PathString(p.basename(asString));

  PathString get basenameWithoutExtension =>
      PathString(p.basenameWithoutExtension(asString));

  PathString get extension => PathString(p.extension(asString));

  bool get isDirectorySync => FileSystemEntity.isDirectorySync(asString);

  bool get isEnabled => !startsWith('DISABLED');

  PathString get enabledForm {
    if (!isEnabled) return PathString(asString.substring(8).trimLeft());
    return this;
  }

  PathString get disabledForm {
    if (isEnabled) return PathString('DISABLED ${asString.trimLeft()}');
    return this;
  }

  PathString join(PathString str) => PathString(p.join(asString, str.asString));

  bool startsWith(String s) {
    return asString.toLowerCase().startsWith(s.toLowerCase());
  }

  @override
  String toString() => asString;

  @override
  bool operator ==(Object other) {
    if (other is! PathString) return false;
    return p.equals(asString, other.asString);
  }

  @override
  int get hashCode => p.canonicalize(asString).hashCode;
}
