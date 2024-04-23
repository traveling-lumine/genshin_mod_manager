// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppState {
  String? get modRoot => throw _privateConstructorUsedError;
  String? get modExecFile => throw _privateConstructorUsedError;
  String? get launcherFile => throw _privateConstructorUsedError;
  PresetData? get presetData => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppStateCopyWith<AppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
  @useResult
  $Res call(
      {String? modRoot,
      String? modExecFile,
      String? launcherFile,
      PresetData? presetData});

  $PresetDataCopyWith<$Res>? get presetData;
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modRoot = freezed,
    Object? modExecFile = freezed,
    Object? launcherFile = freezed,
    Object? presetData = freezed,
  }) {
    return _then(_value.copyWith(
      modRoot: freezed == modRoot
          ? _value.modRoot
          : modRoot // ignore: cast_nullable_to_non_nullable
              as String?,
      modExecFile: freezed == modExecFile
          ? _value.modExecFile
          : modExecFile // ignore: cast_nullable_to_non_nullable
              as String?,
      launcherFile: freezed == launcherFile
          ? _value.launcherFile
          : launcherFile // ignore: cast_nullable_to_non_nullable
              as String?,
      presetData: freezed == presetData
          ? _value.presetData
          : presetData // ignore: cast_nullable_to_non_nullable
              as PresetData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PresetDataCopyWith<$Res>? get presetData {
    if (_value.presetData == null) {
      return null;
    }

    return $PresetDataCopyWith<$Res>(_value.presetData!, (value) {
      return _then(_value.copyWith(presetData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppStateImplCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory _$$AppStateImplCopyWith(
          _$AppStateImpl value, $Res Function(_$AppStateImpl) then) =
      __$$AppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? modRoot,
      String? modExecFile,
      String? launcherFile,
      PresetData? presetData});

  @override
  $PresetDataCopyWith<$Res>? get presetData;
}

/// @nodoc
class __$$AppStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$AppStateImpl>
    implements _$$AppStateImplCopyWith<$Res> {
  __$$AppStateImplCopyWithImpl(
      _$AppStateImpl _value, $Res Function(_$AppStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modRoot = freezed,
    Object? modExecFile = freezed,
    Object? launcherFile = freezed,
    Object? presetData = freezed,
  }) {
    return _then(_$AppStateImpl(
      modRoot: freezed == modRoot
          ? _value.modRoot
          : modRoot // ignore: cast_nullable_to_non_nullable
              as String?,
      modExecFile: freezed == modExecFile
          ? _value.modExecFile
          : modExecFile // ignore: cast_nullable_to_non_nullable
              as String?,
      launcherFile: freezed == launcherFile
          ? _value.launcherFile
          : launcherFile // ignore: cast_nullable_to_non_nullable
              as String?,
      presetData: freezed == presetData
          ? _value.presetData
          : presetData // ignore: cast_nullable_to_non_nullable
              as PresetData?,
    ));
  }
}

/// @nodoc

class _$AppStateImpl with DiagnosticableTreeMixin implements _AppState {
  const _$AppStateImpl(
      {this.modRoot, this.modExecFile, this.launcherFile, this.presetData});

  @override
  final String? modRoot;
  @override
  final String? modExecFile;
  @override
  final String? launcherFile;
  @override
  final PresetData? presetData;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AppState(modRoot: $modRoot, modExecFile: $modExecFile, launcherFile: $launcherFile, presetData: $presetData)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AppState'))
      ..add(DiagnosticsProperty('modRoot', modRoot))
      ..add(DiagnosticsProperty('modExecFile', modExecFile))
      ..add(DiagnosticsProperty('launcherFile', launcherFile))
      ..add(DiagnosticsProperty('presetData', presetData));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppStateImpl &&
            (identical(other.modRoot, modRoot) || other.modRoot == modRoot) &&
            (identical(other.modExecFile, modExecFile) ||
                other.modExecFile == modExecFile) &&
            (identical(other.launcherFile, launcherFile) ||
                other.launcherFile == launcherFile) &&
            (identical(other.presetData, presetData) ||
                other.presetData == presetData));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, modRoot, modExecFile, launcherFile, presetData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      __$$AppStateImplCopyWithImpl<_$AppStateImpl>(this, _$identity);
}

abstract class _AppState implements AppState {
  const factory _AppState(
      {final String? modRoot,
      final String? modExecFile,
      final String? launcherFile,
      final PresetData? presetData}) = _$AppStateImpl;

  @override
  String? get modRoot;
  @override
  String? get modExecFile;
  @override
  String? get launcherFile;
  @override
  PresetData? get presetData;
  @override
  @JsonKey(ignore: true)
  _$$AppStateImplCopyWith<_$AppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
