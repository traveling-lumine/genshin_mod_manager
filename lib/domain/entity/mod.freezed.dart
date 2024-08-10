// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mod.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Mod {
  String get path => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  ModCategory get category => throw _privateConstructorUsedError;

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModCopyWith<Mod> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModCopyWith<$Res> {
  factory $ModCopyWith(Mod value, $Res Function(Mod) then) =
      _$ModCopyWithImpl<$Res, Mod>;
  @useResult
  $Res call(
      {String path, String displayName, bool isEnabled, ModCategory category});

  $ModCategoryCopyWith<$Res> get category;
}

/// @nodoc
class _$ModCopyWithImpl<$Res, $Val extends Mod> implements $ModCopyWith<$Res> {
  _$ModCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? displayName = null,
    Object? isEnabled = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ModCategory,
    ) as $Val);
  }

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModCategoryCopyWith<$Res> get category {
    return $ModCategoryCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ModImplCopyWith<$Res> implements $ModCopyWith<$Res> {
  factory _$$ModImplCopyWith(_$ModImpl value, $Res Function(_$ModImpl) then) =
      __$$ModImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String path, String displayName, bool isEnabled, ModCategory category});

  @override
  $ModCategoryCopyWith<$Res> get category;
}

/// @nodoc
class __$$ModImplCopyWithImpl<$Res> extends _$ModCopyWithImpl<$Res, _$ModImpl>
    implements _$$ModImplCopyWith<$Res> {
  __$$ModImplCopyWithImpl(_$ModImpl _value, $Res Function(_$ModImpl) _then)
      : super(_value, _then);

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? displayName = null,
    Object? isEnabled = null,
    Object? category = null,
  }) {
    return _then(_$ModImpl(
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ModCategory,
    ));
  }
}

/// @nodoc

class _$ModImpl with DiagnosticableTreeMixin implements _Mod {
  const _$ModImpl(
      {required this.path,
      required this.displayName,
      required this.isEnabled,
      required this.category});

  @override
  final String path;
  @override
  final String displayName;
  @override
  final bool isEnabled;
  @override
  final ModCategory category;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Mod(path: $path, displayName: $displayName, isEnabled: $isEnabled, category: $category)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Mod'))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('displayName', displayName))
      ..add(DiagnosticsProperty('isEnabled', isEnabled))
      ..add(DiagnosticsProperty('category', category));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, path, displayName, isEnabled, category);

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModImplCopyWith<_$ModImpl> get copyWith =>
      __$$ModImplCopyWithImpl<_$ModImpl>(this, _$identity);
}

abstract class _Mod implements Mod {
  const factory _Mod(
      {required final String path,
      required final String displayName,
      required final bool isEnabled,
      required final ModCategory category}) = _$ModImpl;

  @override
  String get path;
  @override
  String get displayName;
  @override
  bool get isEnabled;
  @override
  ModCategory get category;

  /// Create a copy of Mod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModImplCopyWith<_$ModImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
