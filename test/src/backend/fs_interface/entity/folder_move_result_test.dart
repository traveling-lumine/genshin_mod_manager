import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/backend/fs_interface/entity/folder_move_result.dart';

void main() {
  late FolderMoveResult folderMoveResult;
  setUp(() {
    folderMoveResult = FolderMoveResult();
  });
  test('Test addError', () {
    const error = FileSystemException('message');
    folderMoveResult.addError(error);
    expect(folderMoveResult.errors, [error]);
  });
  test('Test addExists', () {
    const source = 'source';
    const destination = 'destination';
    folderMoveResult.addExists(source, destination);
    expect(
      folderMoveResult.exists,
      [const FolderMoveExistEntry(source: source, destination: destination)],
    );
  });
  group('Test unmodifiable', () {
    test('Test errors', () {
      folderMoveResult.addError(const FileSystemException('message'));
      final errors = folderMoveResult.errors;
      expect(
        () => errors.add(const FileSystemException('message')),
        throwsUnsupportedError,
      );
    });
    test('Test exists', () {
      folderMoveResult.addExists('source', 'destination');
      final exists = folderMoveResult.exists;
      expect(
        () => exists.add(
          const FolderMoveExistEntry(
            source: 'source',
            destination: 'destination',
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
