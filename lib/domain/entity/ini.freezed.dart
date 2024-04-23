// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ini.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$IniFile {
  String get path => throw _privateConstructorUsedError;
  Mod get mod => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IniFileCopyWith<IniFile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IniFileCopyWith<$Res> {
  factory $IniFileCopyWith(IniFile value, $Res Function(IniFile) then) =
      _$IniFileCopyWithImpl<$Res, IniFile>;
  @useResult
  $Res call({String path, Mod mod});

  $ModCopyWith<$Res> get mod;
}

/// @nodoc
class _$IniFileCopyWithImpl<$Res, $Val extends IniFile>
    implements $IniFileCopyWith<$Res> {
  _$IniFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? mod = null,
  }) {
    return _then(_value.copyWith(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      mod: null == mod
          ? _value.mod
          : mod // ignore: cast_nullable_to_non_nullable
              as Mod,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ModCopyWith<$Res> get mod {
    return $ModCopyWith<$Res>(_value.mod, (value) {
      return _then(_value.copyWith(mod: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IniFileImplCopyWith<$Res> implements $IniFileCopyWith<$Res> {
  factory _$$IniFileImplCopyWith(
          _$IniFileImpl value, $Res Function(_$IniFileImpl) then) =
      __$$IniFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String path, Mod mod});

  @override
  $ModCopyWith<$Res> get mod;
}

/// @nodoc
class __$$IniFileImplCopyWithImpl<$Res>
    extends _$IniFileCopyWithImpl<$Res, _$IniFileImpl>
    implements _$$IniFileImplCopyWith<$Res> {
  __$$IniFileImplCopyWithImpl(
      _$IniFileImpl _value, $Res Function(_$IniFileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? mod = null,
  }) {
    return _then(_$IniFileImpl(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      mod: null == mod
          ? _value.mod
          : mod // ignore: cast_nullable_to_non_nullable
              as Mod,
    ));
  }
}

/// @nodoc

class _$IniFileImpl with DiagnosticableTreeMixin implements _IniFile {
  const _$IniFileImpl({required this.path, required this.mod});

  @override
  final String path;
  @override
  final Mod mod;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'IniFile(path: $path, mod: $mod)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'IniFile'))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('mod', mod));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IniFileImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.mod, mod) || other.mod == mod));
  }

  @override
  int get hashCode => Object.hash(runtimeType, path, mod);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IniFileImplCopyWith<_$IniFileImpl> get copyWith =>
      __$$IniFileImplCopyWithImpl<_$IniFileImpl>(this, _$identity);
}

abstract class _IniFile implements IniFile {
  const factory _IniFile({required final String path, required final Mod mod}) =
      _$IniFileImpl;

  @override
  String get path;
  @override
  Mod get mod;
  @override
  @JsonKey(ignore: true)
  _$$IniFileImplCopyWith<_$IniFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IniSection {
  IniFile get iniFile => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get line => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IniSectionCopyWith<IniSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IniSectionCopyWith<$Res> {
  factory $IniSectionCopyWith(
          IniSection value, $Res Function(IniSection) then) =
      _$IniSectionCopyWithImpl<$Res, IniSection>;
  @useResult
  $Res call({IniFile iniFile, String section, String line});

  $IniFileCopyWith<$Res> get iniFile;
}

/// @nodoc
class _$IniSectionCopyWithImpl<$Res, $Val extends IniSection>
    implements $IniSectionCopyWith<$Res> {
  _$IniSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iniFile = null,
    Object? section = null,
    Object? line = null,
  }) {
    return _then(_value.copyWith(
      iniFile: null == iniFile
          ? _value.iniFile
          : iniFile // ignore: cast_nullable_to_non_nullable
              as IniFile,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IniFileCopyWith<$Res> get iniFile {
    return $IniFileCopyWith<$Res>(_value.iniFile, (value) {
      return _then(_value.copyWith(iniFile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IniSectionImplCopyWith<$Res>
    implements $IniSectionCopyWith<$Res> {
  factory _$$IniSectionImplCopyWith(
          _$IniSectionImpl value, $Res Function(_$IniSectionImpl) then) =
      __$$IniSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({IniFile iniFile, String section, String line});

  @override
  $IniFileCopyWith<$Res> get iniFile;
}

/// @nodoc
class __$$IniSectionImplCopyWithImpl<$Res>
    extends _$IniSectionCopyWithImpl<$Res, _$IniSectionImpl>
    implements _$$IniSectionImplCopyWith<$Res> {
  __$$IniSectionImplCopyWithImpl(
      _$IniSectionImpl _value, $Res Function(_$IniSectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iniFile = null,
    Object? section = null,
    Object? line = null,
  }) {
    return _then(_$IniSectionImpl(
      iniFile: null == iniFile
          ? _value.iniFile
          : iniFile // ignore: cast_nullable_to_non_nullable
              as IniFile,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$IniSectionImpl extends _IniSection with DiagnosticableTreeMixin {
  const _$IniSectionImpl(
      {required this.iniFile, required this.section, required this.line})
      : super._();

  @override
  final IniFile iniFile;
  @override
  final String section;
  @override
  final String line;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'IniSection(iniFile: $iniFile, section: $section, line: $line)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'IniSection'))
      ..add(DiagnosticsProperty('iniFile', iniFile))
      ..add(DiagnosticsProperty('section', section))
      ..add(DiagnosticsProperty('line', line));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IniSectionImpl &&
            (identical(other.iniFile, iniFile) || other.iniFile == iniFile) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.line, line) || other.line == line));
  }

  @override
  int get hashCode => Object.hash(runtimeType, iniFile, section, line);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IniSectionImplCopyWith<_$IniSectionImpl> get copyWith =>
      __$$IniSectionImplCopyWithImpl<_$IniSectionImpl>(this, _$identity);
}

abstract class _IniSection extends IniSection {
  const factory _IniSection(
      {required final IniFile iniFile,
      required final String section,
      required final String line}) = _$IniSectionImpl;
  const _IniSection._() : super._();

  @override
  IniFile get iniFile;
  @override
  String get section;
  @override
  String get line;
  @override
  @JsonKey(ignore: true)
  _$$IniSectionImplCopyWith<_$IniSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
