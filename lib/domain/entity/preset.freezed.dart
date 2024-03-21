// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresetData _$PresetDataFromJson(Map<String, dynamic> json) {
  return _PresetData.fromJson(json);
}

/// @nodoc
mixin _$PresetData {
  Map<String, BundledPresetData> get global =>
      throw _privateConstructorUsedError;
  Map<String, BundledPresetData> get local =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PresetDataCopyWith<PresetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetDataCopyWith<$Res> {
  factory $PresetDataCopyWith(
          PresetData value, $Res Function(PresetData) then) =
      _$PresetDataCopyWithImpl<$Res, PresetData>;
  @useResult
  $Res call(
      {Map<String, BundledPresetData> global,
      Map<String, BundledPresetData> local});
}

/// @nodoc
class _$PresetDataCopyWithImpl<$Res, $Val extends PresetData>
    implements $PresetDataCopyWith<$Res> {
  _$PresetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? global = null,
    Object? local = null,
  }) {
    return _then(_value.copyWith(
      global: null == global
          ? _value.global
          : global // ignore: cast_nullable_to_non_nullable
              as Map<String, BundledPresetData>,
      local: null == local
          ? _value.local
          : local // ignore: cast_nullable_to_non_nullable
              as Map<String, BundledPresetData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresetDataImplCopyWith<$Res>
    implements $PresetDataCopyWith<$Res> {
  factory _$$PresetDataImplCopyWith(
          _$PresetDataImpl value, $Res Function(_$PresetDataImpl) then) =
      __$$PresetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, BundledPresetData> global,
      Map<String, BundledPresetData> local});
}

/// @nodoc
class __$$PresetDataImplCopyWithImpl<$Res>
    extends _$PresetDataCopyWithImpl<$Res, _$PresetDataImpl>
    implements _$$PresetDataImplCopyWith<$Res> {
  __$$PresetDataImplCopyWithImpl(
      _$PresetDataImpl _value, $Res Function(_$PresetDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? global = null,
    Object? local = null,
  }) {
    return _then(_$PresetDataImpl(
      global: null == global
          ? _value._global
          : global // ignore: cast_nullable_to_non_nullable
              as Map<String, BundledPresetData>,
      local: null == local
          ? _value._local
          : local // ignore: cast_nullable_to_non_nullable
              as Map<String, BundledPresetData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetDataImpl with DiagnosticableTreeMixin implements _PresetData {
  const _$PresetDataImpl(
      {required final Map<String, BundledPresetData> global,
      required final Map<String, BundledPresetData> local})
      : _global = global,
        _local = local;

  factory _$PresetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetDataImplFromJson(json);

  final Map<String, BundledPresetData> _global;
  @override
  Map<String, BundledPresetData> get global {
    if (_global is EqualUnmodifiableMapView) return _global;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_global);
  }

  final Map<String, BundledPresetData> _local;
  @override
  Map<String, BundledPresetData> get local {
    if (_local is EqualUnmodifiableMapView) return _local;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_local);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PresetData(global: $global, local: $local)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PresetData'))
      ..add(DiagnosticsProperty('global', global))
      ..add(DiagnosticsProperty('local', local));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetDataImpl &&
            const DeepCollectionEquality().equals(other._global, _global) &&
            const DeepCollectionEquality().equals(other._local, _local));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_global),
      const DeepCollectionEquality().hash(_local));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PresetDataImplCopyWith<_$PresetDataImpl> get copyWith =>
      __$$PresetDataImplCopyWithImpl<_$PresetDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresetDataImplToJson(
      this,
    );
  }
}

abstract class _PresetData implements PresetData {
  const factory _PresetData(
      {required final Map<String, BundledPresetData> global,
      required final Map<String, BundledPresetData> local}) = _$PresetDataImpl;

  factory _PresetData.fromJson(Map<String, dynamic> json) =
      _$PresetDataImpl.fromJson;

  @override
  Map<String, BundledPresetData> get global;
  @override
  Map<String, BundledPresetData> get local;
  @override
  @JsonKey(ignore: true)
  _$$PresetDataImplCopyWith<_$PresetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BundledPresetData _$BundledPresetDataFromJson(Map<String, dynamic> json) {
  return _BundledPresetData.fromJson(json);
}

/// @nodoc
mixin _$BundledPresetData {
  Map<String, PresetTargetData> get bundledPresets =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BundledPresetDataCopyWith<BundledPresetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BundledPresetDataCopyWith<$Res> {
  factory $BundledPresetDataCopyWith(
          BundledPresetData value, $Res Function(BundledPresetData) then) =
      _$BundledPresetDataCopyWithImpl<$Res, BundledPresetData>;
  @useResult
  $Res call({Map<String, PresetTargetData> bundledPresets});
}

/// @nodoc
class _$BundledPresetDataCopyWithImpl<$Res, $Val extends BundledPresetData>
    implements $BundledPresetDataCopyWith<$Res> {
  _$BundledPresetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bundledPresets = null,
  }) {
    return _then(_value.copyWith(
      bundledPresets: null == bundledPresets
          ? _value.bundledPresets
          : bundledPresets // ignore: cast_nullable_to_non_nullable
              as Map<String, PresetTargetData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BundledPresetDataImplCopyWith<$Res>
    implements $BundledPresetDataCopyWith<$Res> {
  factory _$$BundledPresetDataImplCopyWith(_$BundledPresetDataImpl value,
          $Res Function(_$BundledPresetDataImpl) then) =
      __$$BundledPresetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, PresetTargetData> bundledPresets});
}

/// @nodoc
class __$$BundledPresetDataImplCopyWithImpl<$Res>
    extends _$BundledPresetDataCopyWithImpl<$Res, _$BundledPresetDataImpl>
    implements _$$BundledPresetDataImplCopyWith<$Res> {
  __$$BundledPresetDataImplCopyWithImpl(_$BundledPresetDataImpl _value,
      $Res Function(_$BundledPresetDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bundledPresets = null,
  }) {
    return _then(_$BundledPresetDataImpl(
      bundledPresets: null == bundledPresets
          ? _value._bundledPresets
          : bundledPresets // ignore: cast_nullable_to_non_nullable
              as Map<String, PresetTargetData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BundledPresetDataImpl
    with DiagnosticableTreeMixin
    implements _BundledPresetData {
  const _$BundledPresetDataImpl(
      {required final Map<String, PresetTargetData> bundledPresets})
      : _bundledPresets = bundledPresets;

  factory _$BundledPresetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BundledPresetDataImplFromJson(json);

  final Map<String, PresetTargetData> _bundledPresets;
  @override
  Map<String, PresetTargetData> get bundledPresets {
    if (_bundledPresets is EqualUnmodifiableMapView) return _bundledPresets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bundledPresets);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BundledPresetData(bundledPresets: $bundledPresets)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BundledPresetData'))
      ..add(DiagnosticsProperty('bundledPresets', bundledPresets));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BundledPresetDataImpl &&
            const DeepCollectionEquality()
                .equals(other._bundledPresets, _bundledPresets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_bundledPresets));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BundledPresetDataImplCopyWith<_$BundledPresetDataImpl> get copyWith =>
      __$$BundledPresetDataImplCopyWithImpl<_$BundledPresetDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BundledPresetDataImplToJson(
      this,
    );
  }
}

abstract class _BundledPresetData implements BundledPresetData {
  const factory _BundledPresetData(
          {required final Map<String, PresetTargetData> bundledPresets}) =
      _$BundledPresetDataImpl;

  factory _BundledPresetData.fromJson(Map<String, dynamic> json) =
      _$BundledPresetDataImpl.fromJson;

  @override
  Map<String, PresetTargetData> get bundledPresets;
  @override
  @JsonKey(ignore: true)
  _$$BundledPresetDataImplCopyWith<_$BundledPresetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PresetTargetData _$PresetTargetDataFromJson(Map<String, dynamic> json) {
  return _PresetTargetData.fromJson(json);
}

/// @nodoc
mixin _$PresetTargetData {
  List<String> get mods => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PresetTargetDataCopyWith<PresetTargetData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetTargetDataCopyWith<$Res> {
  factory $PresetTargetDataCopyWith(
          PresetTargetData value, $Res Function(PresetTargetData) then) =
      _$PresetTargetDataCopyWithImpl<$Res, PresetTargetData>;
  @useResult
  $Res call({List<String> mods});
}

/// @nodoc
class _$PresetTargetDataCopyWithImpl<$Res, $Val extends PresetTargetData>
    implements $PresetTargetDataCopyWith<$Res> {
  _$PresetTargetDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mods = null,
  }) {
    return _then(_value.copyWith(
      mods: null == mods
          ? _value.mods
          : mods // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresetTargetDataImplCopyWith<$Res>
    implements $PresetTargetDataCopyWith<$Res> {
  factory _$$PresetTargetDataImplCopyWith(_$PresetTargetDataImpl value,
          $Res Function(_$PresetTargetDataImpl) then) =
      __$$PresetTargetDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> mods});
}

/// @nodoc
class __$$PresetTargetDataImplCopyWithImpl<$Res>
    extends _$PresetTargetDataCopyWithImpl<$Res, _$PresetTargetDataImpl>
    implements _$$PresetTargetDataImplCopyWith<$Res> {
  __$$PresetTargetDataImplCopyWithImpl(_$PresetTargetDataImpl _value,
      $Res Function(_$PresetTargetDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mods = null,
  }) {
    return _then(_$PresetTargetDataImpl(
      mods: null == mods
          ? _value._mods
          : mods // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetTargetDataImpl
    with DiagnosticableTreeMixin
    implements _PresetTargetData {
  const _$PresetTargetDataImpl({required final List<String> mods})
      : _mods = mods;

  factory _$PresetTargetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetTargetDataImplFromJson(json);

  final List<String> _mods;
  @override
  List<String> get mods {
    if (_mods is EqualUnmodifiableListView) return _mods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mods);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PresetTargetData(mods: $mods)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PresetTargetData'))
      ..add(DiagnosticsProperty('mods', mods));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetTargetDataImpl &&
            const DeepCollectionEquality().equals(other._mods, _mods));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_mods));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PresetTargetDataImplCopyWith<_$PresetTargetDataImpl> get copyWith =>
      __$$PresetTargetDataImplCopyWithImpl<_$PresetTargetDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresetTargetDataImplToJson(
      this,
    );
  }
}

abstract class _PresetTargetData implements PresetTargetData {
  const factory _PresetTargetData({required final List<String> mods}) =
      _$PresetTargetDataImpl;

  factory _PresetTargetData.fromJson(Map<String, dynamic> json) =
      _$PresetTargetDataImpl.fromJson;

  @override
  List<String> get mods;
  @override
  @JsonKey(ignore: true)
  _$$PresetTargetDataImplCopyWith<_$PresetTargetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
