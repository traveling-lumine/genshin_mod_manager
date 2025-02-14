import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_move_result.freezed.dart';

class FolderMoveResult {
  FolderMoveResult();
  final List<FileSystemException> _errors = [];
  final List<FolderMoveExistEntry> _exists = [];

  List<FileSystemException> get errors => UnmodifiableListView(_errors);
  List<FolderMoveExistEntry> get exists => UnmodifiableListView(_exists);

  void addError(final FileSystemException e) {
    _errors.add(e);
  }

  void addExists(final String source, final String destination) {
    _exists.add(FolderMoveExistEntry(source: source, destination: destination));
  }
}

@freezed
class FolderMoveExistEntry with _$FolderMoveExistEntry {
  const factory FolderMoveExistEntry({
    required final String source,
    required final String destination,
  }) = _FolderMoveExistEntry;
}
