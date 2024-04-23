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
  Map<String, PresetListMap> get global => throw _privateConstructorUsedError;
  Map<String, PresetListMap> get local => throw _privateConstructorUsedError;

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
      {Map<String, PresetListMap> global, Map<String, PresetListMap> local});
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
              as Map<String, PresetListMap>,
      local: null == local
          ? _value.local
          : local // ignore: cast_nullable_to_non_nullable
              as Map<String, PresetListMap>,
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
      {Map<String, PresetListMap> global, Map<String, PresetListMap> local});
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
              as Map<String, PresetListMap>,
      local: null == local
          ? _value._local
          : local // ignore: cast_nullable_to_non_nullable
              as Map<String, PresetListMap>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetDataImpl with DiagnosticableTreeMixin implements _PresetData {
  const _$PresetDataImpl(
      {required final Map<String, PresetListMap> global,
      required final Map<String, PresetListMap> local})
      : _global = global,
        _local = local;

  factory _$PresetDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetDataImplFromJson(json);

  final Map<String, PresetListMap> _global;
  @override
  Map<String, PresetListMap> get global {
    if (_global is EqualUnmodifiableMapView) return _global;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_global);
  }

  final Map<String, PresetListMap> _local;
  @override
  Map<String, PresetListMap> get local {
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
      {required final Map<String, PresetListMap> global,
      required final Map<String, PresetListMap> local}) = _$PresetDataImpl;

  factory _PresetData.fromJson(Map<String, dynamic> json) =
      _$PresetDataImpl.fromJson;

  @override
  Map<String, PresetListMap> get global;
  @override
  Map<String, PresetListMap> get local;
  @override
  @JsonKey(ignore: true)
  _$$PresetDataImplCopyWith<_$PresetDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PresetListMap _$PresetListMapFromJson(Map<String, dynamic> json) {
  return _PresetListMap.fromJson(json);
}

/// @nodoc
mixin _$PresetListMap {
  Map<String, PresetList> get bundledPresets =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PresetListMapCopyWith<PresetListMap> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetListMapCopyWith<$Res> {
  factory $PresetListMapCopyWith(
          PresetListMap value, $Res Function(PresetListMap) then) =
      _$PresetListMapCopyWithImpl<$Res, PresetListMap>;
  @useResult
  $Res call({Map<String, PresetList> bundledPresets});
}

/// @nodoc
class _$PresetListMapCopyWithImpl<$Res, $Val extends PresetListMap>
    implements $PresetListMapCopyWith<$Res> {
  _$PresetListMapCopyWithImpl(this._value, this._then);

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
              as Map<String, PresetList>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresetListMapImplCopyWith<$Res>
    implements $PresetListMapCopyWith<$Res> {
  factory _$$PresetListMapImplCopyWith(
          _$PresetListMapImpl value, $Res Function(_$PresetListMapImpl) then) =
      __$$PresetListMapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, PresetList> bundledPresets});
}

/// @nodoc
class __$$PresetListMapImplCopyWithImpl<$Res>
    extends _$PresetListMapCopyWithImpl<$Res, _$PresetListMapImpl>
    implements _$$PresetListMapImplCopyWith<$Res> {
  __$$PresetListMapImplCopyWithImpl(
      _$PresetListMapImpl _value, $Res Function(_$PresetListMapImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bundledPresets = null,
  }) {
    return _then(_$PresetListMapImpl(
      bundledPresets: null == bundledPresets
          ? _value._bundledPresets
          : bundledPresets // ignore: cast_nullable_to_non_nullable
              as Map<String, PresetList>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetListMapImpl
    with DiagnosticableTreeMixin
    implements _PresetListMap {
  const _$PresetListMapImpl(
      {required final Map<String, PresetList> bundledPresets})
      : _bundledPresets = bundledPresets;

  factory _$PresetListMapImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetListMapImplFromJson(json);

  final Map<String, PresetList> _bundledPresets;
  @override
  Map<String, PresetList> get bundledPresets {
    if (_bundledPresets is EqualUnmodifiableMapView) return _bundledPresets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bundledPresets);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PresetListMap(bundledPresets: $bundledPresets)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PresetListMap'))
      ..add(DiagnosticsProperty('bundledPresets', bundledPresets));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetListMapImpl &&
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
  _$$PresetListMapImplCopyWith<_$PresetListMapImpl> get copyWith =>
      __$$PresetListMapImplCopyWithImpl<_$PresetListMapImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresetListMapImplToJson(
      this,
    );
  }
}

abstract class _PresetListMap implements PresetListMap {
  const factory _PresetListMap(
          {required final Map<String, PresetList> bundledPresets}) =
      _$PresetListMapImpl;

  factory _PresetListMap.fromJson(Map<String, dynamic> json) =
      _$PresetListMapImpl.fromJson;

  @override
  Map<String, PresetList> get bundledPresets;
  @override
  @JsonKey(ignore: true)
  _$$PresetListMapImplCopyWith<_$PresetListMapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PresetList _$PresetListFromJson(Map<String, dynamic> json) {
  return _PresetList.fromJson(json);
}

/// @nodoc
mixin _$PresetList {
  List<String> get mods => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PresetListCopyWith<PresetList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresetListCopyWith<$Res> {
  factory $PresetListCopyWith(
          PresetList value, $Res Function(PresetList) then) =
      _$PresetListCopyWithImpl<$Res, PresetList>;
  @useResult
  $Res call({List<String> mods});
}

/// @nodoc
class _$PresetListCopyWithImpl<$Res, $Val extends PresetList>
    implements $PresetListCopyWith<$Res> {
  _$PresetListCopyWithImpl(this._value, this._then);

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
abstract class _$$PresetListImplCopyWith<$Res>
    implements $PresetListCopyWith<$Res> {
  factory _$$PresetListImplCopyWith(
          _$PresetListImpl value, $Res Function(_$PresetListImpl) then) =
      __$$PresetListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> mods});
}

/// @nodoc
class __$$PresetListImplCopyWithImpl<$Res>
    extends _$PresetListCopyWithImpl<$Res, _$PresetListImpl>
    implements _$$PresetListImplCopyWith<$Res> {
  __$$PresetListImplCopyWithImpl(
      _$PresetListImpl _value, $Res Function(_$PresetListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mods = null,
  }) {
    return _then(_$PresetListImpl(
      mods: null == mods
          ? _value._mods
          : mods // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresetListImpl with DiagnosticableTreeMixin implements _PresetList {
  const _$PresetListImpl({required final List<String> mods}) : _mods = mods;

  factory _$PresetListImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresetListImplFromJson(json);

  final List<String> _mods;
  @override
  List<String> get mods {
    if (_mods is EqualUnmodifiableListView) return _mods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mods);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PresetList(mods: $mods)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PresetList'))
      ..add(DiagnosticsProperty('mods', mods));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresetListImpl &&
            const DeepCollectionEquality().equals(other._mods, _mods));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_mods));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PresetListImplCopyWith<_$PresetListImpl> get copyWith =>
      __$$PresetListImplCopyWithImpl<_$PresetListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresetListImplToJson(
      this,
    );
  }
}

abstract class _PresetList implements PresetList {
  const factory _PresetList({required final List<String> mods}) =
      _$PresetListImpl;

  factory _PresetList.fromJson(Map<String, dynamic> json) =
      _$PresetListImpl.fromJson;

  @override
  List<String> get mods;
  @override
  @JsonKey(ignore: true)
  _$$PresetListImplCopyWith<_$PresetListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
