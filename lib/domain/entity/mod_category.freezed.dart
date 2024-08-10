// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mod_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ModCategory _$ModCategoryFromJson(Map<String, dynamic> json) {
  return _ModCategory.fromJson(json);
}

/// @nodoc
mixin _$ModCategory {
  String get path => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get iconPath => throw _privateConstructorUsedError;

  /// Serializes this ModCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModCategoryCopyWith<ModCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModCategoryCopyWith<$Res> {
  factory $ModCategoryCopyWith(
          ModCategory value, $Res Function(ModCategory) then) =
      _$ModCategoryCopyWithImpl<$Res, ModCategory>;
  @useResult
  $Res call({String path, String name, String? iconPath});
}

/// @nodoc
class _$ModCategoryCopyWithImpl<$Res, $Val extends ModCategory>
    implements $ModCategoryCopyWith<$Res> {
  _$ModCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? name = null,
    Object? iconPath = freezed,
  }) {
    return _then(_value.copyWith(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModCategoryImplCopyWith<$Res>
    implements $ModCategoryCopyWith<$Res> {
  factory _$$ModCategoryImplCopyWith(
          _$ModCategoryImpl value, $Res Function(_$ModCategoryImpl) then) =
      __$$ModCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String path, String name, String? iconPath});
}

/// @nodoc
class __$$ModCategoryImplCopyWithImpl<$Res>
    extends _$ModCategoryCopyWithImpl<$Res, _$ModCategoryImpl>
    implements _$$ModCategoryImplCopyWith<$Res> {
  __$$ModCategoryImplCopyWithImpl(
      _$ModCategoryImpl _value, $Res Function(_$ModCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? name = null,
    Object? iconPath = freezed,
  }) {
    return _then(_$ModCategoryImpl(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModCategoryImpl with DiagnosticableTreeMixin implements _ModCategory {
  const _$ModCategoryImpl(
      {required this.path, required this.name, this.iconPath});

  factory _$ModCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModCategoryImplFromJson(json);

  @override
  final String path;
  @override
  final String name;
  @override
  final String? iconPath;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ModCategory(path: $path, name: $name, iconPath: $iconPath)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ModCategory'))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('iconPath', iconPath));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModCategoryImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, path, name, iconPath);

  /// Create a copy of ModCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModCategoryImplCopyWith<_$ModCategoryImpl> get copyWith =>
      __$$ModCategoryImplCopyWithImpl<_$ModCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModCategoryImplToJson(
      this,
    );
  }
}

abstract class _ModCategory implements ModCategory {
  const factory _ModCategory(
      {required final String path,
      required final String name,
      final String? iconPath}) = _$ModCategoryImpl;

  factory _ModCategory.fromJson(Map<String, dynamic> json) =
      _$ModCategoryImpl.fromJson;

  @override
  String get path;
  @override
  String get name;
  @override
  String? get iconPath;

  /// Create a copy of ModCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModCategoryImplCopyWith<_$ModCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
