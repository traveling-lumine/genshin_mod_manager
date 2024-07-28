import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';

part 'ini.freezed.dart';

@freezed
class IniFile with _$IniFile {
  const factory IniFile({
    required final String path,
    required final Mod mod,
  }) = _IniFile;
}

@freezed
class IniSection with _$IniSection {
  const factory IniSection({
    required final IniFile iniFile,
    required final String section,
    required final String line,
  }) = _IniSection;

  const IniSection._();

  String get key => line.split('=')[0].trim();

  String get value => line.split('=')[1].trim();
}
