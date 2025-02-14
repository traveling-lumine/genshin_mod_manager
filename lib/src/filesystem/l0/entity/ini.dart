import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'mod.dart';

part 'ini.freezed.dart';

@freezed
class IniFile with _$IniFile {
  const factory IniFile({
    required final String path,
    required final Mod mod,
  }) = _IniFile;
}

@freezed
sealed class IniStatement with _$IniStatement {
  const factory IniStatement.section({
    required final IniFile iniFile,
    required final int lineNum,
    required final String name,
  }) = IniStatementSection;

  const factory IniStatement.forward({
    required final int lineNum,
    required final IniStatementSection section,
    required final String value,
  }) = IniStatementForward;

  const factory IniStatement.backward({
    required final int lineNum,
    required final IniStatementSection section,
    required final String value,
  }) = IniStatementBackward;

  const factory IniStatement.variable({
    required final int lineNum,
    required final IniStatementSection section,
    required final String name,
    required final int numCycles,
  }) = IniStatementVariable;
}
