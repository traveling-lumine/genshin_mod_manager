// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GameConfig {
  String? get modRoot => throw _privateConstructorUsedError;
  String? get modExecFile => throw _privateConstructorUsedError;
  String? get launcherFile => throw _privateConstructorUsedError;
  PresetData? get presetData => throw _privateConstructorUsedError;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameConfigCopyWith<GameConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameConfigCopyWith<$Res> {
  factory $GameConfigCopyWith(
          GameConfig value, $Res Function(GameConfig) then) =
      _$GameConfigCopyWithImpl<$Res, GameConfig>;
  @useResult
  $Res call(
      {String? modRoot,
      String? modExecFile,
      String? launcherFile,
      PresetData? presetData});

  $PresetDataCopyWith<$Res>? get presetData;
}

/// @nodoc
class _$GameConfigCopyWithImpl<$Res, $Val extends GameConfig>
    implements $GameConfigCopyWith<$Res> {
  _$GameConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$GameConfigImplCopyWith<$Res>
    implements $GameConfigCopyWith<$Res> {
  factory _$$GameConfigImplCopyWith(
          _$GameConfigImpl value, $Res Function(_$GameConfigImpl) then) =
      __$$GameConfigImplCopyWithImpl<$Res>;
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
class __$$GameConfigImplCopyWithImpl<$Res>
    extends _$GameConfigCopyWithImpl<$Res, _$GameConfigImpl>
    implements _$$GameConfigImplCopyWith<$Res> {
  __$$GameConfigImplCopyWithImpl(
      _$GameConfigImpl _value, $Res Function(_$GameConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modRoot = freezed,
    Object? modExecFile = freezed,
    Object? launcherFile = freezed,
    Object? presetData = freezed,
  }) {
    return _then(_$GameConfigImpl(
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

class _$GameConfigImpl with DiagnosticableTreeMixin implements _GameConfig {
  const _$GameConfigImpl(
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
    return 'GameConfig(modRoot: $modRoot, modExecFile: $modExecFile, launcherFile: $launcherFile, presetData: $presetData)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'GameConfig'))
      ..add(DiagnosticsProperty('modRoot', modRoot))
      ..add(DiagnosticsProperty('modExecFile', modExecFile))
      ..add(DiagnosticsProperty('launcherFile', launcherFile))
      ..add(DiagnosticsProperty('presetData', presetData));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameConfigImpl &&
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

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      __$$GameConfigImplCopyWithImpl<_$GameConfigImpl>(this, _$identity);
}

abstract class _GameConfig implements GameConfig {
  const factory _GameConfig(
      {final String? modRoot,
      final String? modExecFile,
      final String? launcherFile,
      final PresetData? presetData}) = _$GameConfigImpl;

  @override
  String? get modRoot;
  @override
  String? get modExecFile;
  @override
  String? get launcherFile;
  @override
  PresetData? get presetData;

  /// Create a copy of GameConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameConfigImplCopyWith<_$GameConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
