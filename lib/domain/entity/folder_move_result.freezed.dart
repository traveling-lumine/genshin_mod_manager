// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_move_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FolderMoveExistEntry {
  String get source => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;

  /// Create a copy of FolderMoveExistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FolderMoveExistEntryCopyWith<FolderMoveExistEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FolderMoveExistEntryCopyWith<$Res> {
  factory $FolderMoveExistEntryCopyWith(FolderMoveExistEntry value,
          $Res Function(FolderMoveExistEntry) then) =
      _$FolderMoveExistEntryCopyWithImpl<$Res, FolderMoveExistEntry>;
  @useResult
  $Res call({String source, String destination});
}

/// @nodoc
class _$FolderMoveExistEntryCopyWithImpl<$Res,
        $Val extends FolderMoveExistEntry>
    implements $FolderMoveExistEntryCopyWith<$Res> {
  _$FolderMoveExistEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FolderMoveExistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? destination = null,
  }) {
    return _then(_value.copyWith(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FolderMoveExistEntryImplCopyWith<$Res>
    implements $FolderMoveExistEntryCopyWith<$Res> {
  factory _$$FolderMoveExistEntryImplCopyWith(_$FolderMoveExistEntryImpl value,
          $Res Function(_$FolderMoveExistEntryImpl) then) =
      __$$FolderMoveExistEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String source, String destination});
}

/// @nodoc
class __$$FolderMoveExistEntryImplCopyWithImpl<$Res>
    extends _$FolderMoveExistEntryCopyWithImpl<$Res, _$FolderMoveExistEntryImpl>
    implements _$$FolderMoveExistEntryImplCopyWith<$Res> {
  __$$FolderMoveExistEntryImplCopyWithImpl(_$FolderMoveExistEntryImpl _value,
      $Res Function(_$FolderMoveExistEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of FolderMoveExistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? destination = null,
  }) {
    return _then(_$FolderMoveExistEntryImpl(
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FolderMoveExistEntryImpl implements _FolderMoveExistEntry {
  const _$FolderMoveExistEntryImpl(
      {required this.source, required this.destination});

  @override
  final String source;
  @override
  final String destination;

  @override
  String toString() {
    return 'FolderMoveExistEntry(source: $source, destination: $destination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FolderMoveExistEntryImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.destination, destination) ||
                other.destination == destination));
  }

  @override
  int get hashCode => Object.hash(runtimeType, source, destination);

  /// Create a copy of FolderMoveExistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FolderMoveExistEntryImplCopyWith<_$FolderMoveExistEntryImpl>
      get copyWith =>
          __$$FolderMoveExistEntryImplCopyWithImpl<_$FolderMoveExistEntryImpl>(
              this, _$identity);
}

abstract class _FolderMoveExistEntry implements FolderMoveExistEntry {
  const factory _FolderMoveExistEntry(
      {required final String source,
      required final String destination}) = _$FolderMoveExistEntryImpl;

  @override
  String get source;
  @override
  String get destination;

  /// Create a copy of FolderMoveExistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FolderMoveExistEntryImplCopyWith<_$FolderMoveExistEntryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
