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

      final stream = fs.watchDirectory(path: 'parent/target');
      File('parent/target/file').createSync();

      await expectLater(
        stream.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
            isA<FileSystemCreateEvent>(),
          ],
        ),
      );

      await stream.cancel();
      await fs.dispose();
    });
    test('non-directory does not throw error', () async {
      final file = File('parent/target/file')..createSync();
      final fs = FilesystemImpl();
      expect(
        () => fs.watchDirectory(path: file.path),
        returnsNormally,
      );
      await fs.dispose();
    });
    group('handle test', () {
      late FilesystemImpl fs;
      late Watcher stream;
      setUp(() {
        fs = FilesystemImpl();
        stream = fs.watchDirectory(path: 'parent/target');
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
      final stream = fs.watchFile(path: 'parent/target');
      File('parent/target').writeAsStringSync('content');

      await expectLater(
        stream.stream,
        emitsInOrder(
          <Matcher>[
            isNull,
            isA<FileSystemModifyEvent>(),
          ],
        ),
      );

      await stream.cancel();
      await fs.dispose();
    });
    test('File watch rejects sibling changes', () async {
      final fs = FilesystemImpl();
      final stream = fs.watchFile(path: 'parent/target');
      File('parent/other').createSync();

      await expectLater(
        stream.stream,
        emitsInOrder(
          <Matcher>[],
        ),
      );

      await stream.cancel();
      await fs.dispose();
    });
    test('File watch receives move ', () async {
      final fs = FilesystemImpl();
      final stream = fs.watchFile(path: 'parent/target');
      File('parent/target').deleteSync();
      File('parent/target3')
        ..createSync()
        ..renameSync('parent/target');

      await expectLater(
        stream.stream,
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

      await stream.cancel();
      await fs.dispose();
    });
    test('non-file does not throw error', () async {
      final dir = Directory('parent/target2')..createSync();
      final fs = FilesystemImpl();
      expect(
        () => fs.watchFile(path: dir.path),
        returnsNormally,
      );
      await fs.dispose();
    });
  });
  test('multiple stream handle test', () async {
    final pdir = Directory('parent')..createSync();
    final wdir = Directory('parent/target')..createSync();
    final wfile = File('parent/target/file')..createSync();
    final fs = FilesystemImpl();
    final stream1 = fs.watchDirectory(path: wdir.path);
    final stream2 = fs.watchFile(path: wfile.path);

    // moving parent should throw
    expect(
      () => pdir.renameSync('parent2'),
      throwsA(isA<FileSystemException>()),
    );

    await Future.wait([
      stream1.cancel(),
      stream2.cancel(),
    ]);

    // moving parent should not throw
    expect(
      () => pdir.renameSync('parent2'),
      returnsNormally,
    );

    await fs.dispose();
  });
}
