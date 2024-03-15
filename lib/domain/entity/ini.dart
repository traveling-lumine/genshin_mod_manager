import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:meta/meta.dart';

@immutable
class IniFile {
  const IniFile({
    required this.path,
    required this.mod,
  });

  final String path;
  final Mod mod;

  @override
  bool operator ==(final Object other) {
    throw UnimplementedError();
  }

  @override
  int get hashCode => throw UnimplementedError();

  @override
  String toString() => 'IniFile(path: $path, mod: $mod)';
}

@immutable
class IniSection {
  IniSection({
    required this.iniFile,
    required this.section,
    required this.line,
  })  : key = line.split('=')[0].trim(),
        value = line.split('=')[1].trim();

  final IniFile iniFile;
  final String section;
  final String line;
  final String key;
  final String value;

  @override
  bool operator ==(final Object other) {
    throw UnimplementedError();
  }

  @override
  int get hashCode => throw UnimplementedError();

  @override
  String toString() => 'IniSection(iniFile: $iniFile, section: $section, '
      'line: $line, key: $key, value: $value)';
}
