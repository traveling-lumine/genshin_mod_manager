import 'dart:collection';
import 'dart:io';

final class FolderMoveResult {
  FolderMoveResult();
  final List<FileSystemException> _errors = [];
  final List<(String, String)> _exists = [];

  List<FileSystemException> get errors => UnmodifiableListView(_errors);
  List<(String, String)> get exists => UnmodifiableListView(_exists);

  void addError(final FileSystemException e) {
    _errors.add(e);
  }

  void addExists(final String source, final String destination) {
    _exists.add((source, destination));
  }
}
