import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/filesystem/l0/api/watcher.dart';
import 'package:genshin_mod_manager/src/filesystem/l1/impl/filesystem.dart';
import 'package:path/path.dart' as p;

void main() {
  final testRoot = Directory('testDirectory');
  late Directory curDir;
  setUp(() {
    curDir = Directory.current;
    testRoot.createSync();
    Directory.current = testRoot;
  });
  tearDown(() {
    Directory.current = curDir;
    testRoot.deleteSync(recursive: true);
  });
  group('Folder watch', () {
    setUp(() {
      Directory('parent/target').createSync(recursive: true);
    });
    tearDown(() {
      Directory('parent').deleteSync(recursive: true);
    });
    test('Watch', () async {
      final fs = FilesystemImpl();
      final ctrl = StreamController<FileSystemEvent?>();

      final stream = fs.watchDirectory(
        path: 'parent/target',
        onEvent: ctrl.add,
      );
      File('parent/target/file').createSync();

      await expectLater(
        ctrl.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
            isA<FileSystemCreateEvent>(),
          ],
        ),
      );

      await ctrl.close();
      await stream.cancel();
      await fs.dispose();
    });
    test('non-directory throws error', () async {
      final file = File('parent/target/file')..createSync();
      final fs = FilesystemImpl();
      expect(
        () => fs.watchDirectory(
          path: file.path,
          onEvent: (final event) {},
        ),
        throwsA(isA<FileSystemException>()),
      );
      await fs.dispose();
    });
    group('handle test', () {
      late FilesystemImpl fs;
      late Watcher stream;
      setUp(() {
        fs = FilesystemImpl();
        stream = fs.watchDirectory(
          path: 'parent/target',
          onEvent: (final event) {},
        );
        expect(
          () => Directory('parent').renameSync('parent2'),
          throwsA(isA<FileSystemException>()),
        );
      });
      tearDown(() async {
        expect(
          () => Directory('parent').renameSync('parent2'),
          returnsNormally,
        );
        Directory('parent2').renameSync('parent');
        await stream.cancel();
        await fs.dispose();
      });
      test(
        'directory is movable after pause',
        () async => fs.pauseAllWatchers(),
      );
      test('directory is movable after cancel', () async => stream.cancel());
      test('directory is movable after dispose', () async => fs.dispose());
      test('directory is not movable after resume', () async {
        await fs.pauseAllWatchers();
        fs.resumeAllWatchers();

        expect(
          () => Directory('parent').renameSync('parent2'),
          throwsA(isA<FileSystemException>()),
        );

        await fs.pauseAllWatchers();
      });
    });
  });
  group('File watch', () {
    setUp(() {
      Directory('parent').createSync(recursive: true);
      File('parent/target').createSync();
    });
    tearDown(() {
      Directory('parent').deleteSync(recursive: true);
    });
    test('Watch', () async {
      final fs = FilesystemImpl();
      final ctrl = StreamController<FileSystemEvent?>();
      final stream = fs.watchFile(
        path: 'parent/target',
        onEvent: ctrl.add,
      );
      File('parent/target').writeAsStringSync('content');

      await expectLater(
        ctrl.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
            isA<FileSystemModifyEvent>(),
          ],
        ),
      );

      await ctrl.close();
      await stream.cancel();
      await fs.dispose();
    });
    test('File watch rejects sibling changes', () async {
      final fs = FilesystemImpl();
      final ctrl = StreamController<FileSystemEvent?>();
      final stream = fs.watchFile(
        path: 'parent/target',
        onEvent: ctrl.add,
      );
      File('parent/other').createSync();

      await expectLater(
        ctrl.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
          ],
        ),
      );

      await ctrl.close();
      await stream.cancel();
      await fs.dispose();
    });
    test('File watch receives move ', () async {
      final fs = FilesystemImpl();
      final ctrl = StreamController<FileSystemEvent?>();
      final stream = fs.watchFile(
        path: 'parent/target',
        onEvent: ctrl.add,
      );
      File('parent/target').deleteSync();
      File('parent/target3')
        ..createSync()
        ..renameSync('parent/target');

      await expectLater(
        ctrl.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
            isA<FileSystemDeleteEvent>(),
            isA<FileSystemMoveEvent>().having(
              (final e) => e.destination,
              'destination',
              predicate<String?>(
                (final p0) => p.equals(p0 ?? '', 'parent/target'),
              ),
            ),
          ],
        ),
      );

      await ctrl.close();
      await stream.cancel();
      await fs.dispose();
    });
    test('non-file throws error', () async {
      final dir = Directory('parent/target2')..createSync();
      final fs = FilesystemImpl();
      expect(
        () => fs.watchFile(
          path: dir.path,
          onEvent: (final event) {},
        ),
        throwsA(isA<FileSystemException>()),
      );
      await fs.dispose();
    });
  });
}
