import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

part 'mod_category.freezed.dart';

@freezed
class ModCategory with _$ModCategory {
  factory ModCategory({
    required final String path,
    required final String name,
  }) =>
      ModCategory._internal(path_: PathString(path), name: name);

  const factory ModCategory._internal({
    required final PathString path_,
    required final String name,
  }) = _ModCategory;

  const ModCategory._();

  String get path => path_.path;
}

@immutable
class PathString {
  const PathString(this.path);
  final String path;

  @override
  bool operator ==(final Object other) =>
      other is PathString && p.equals(path, other.path);

  @override
  int get hashCode => p.hash(path);
}
