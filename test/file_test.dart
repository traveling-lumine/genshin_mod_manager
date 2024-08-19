// ignore_for_file: avoid_slow_async_io, avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('invalid file name', () {
    final file = File('a file?');
    expect(file.existsSync(), isFalse);
    expect(file.createSync, throwsA(isA<FileSystemException>()));
  });
  test(
    'file watch test',
    () async {
      final dir = Directory('test_dir')..createSync();
      final file = File('test_dir/test_file')
        ..createSync()
        ..watch().listen((final event) {
          fail('File should not be watched');
        });
      await Future<void>.delayed(const Duration(seconds: 1));
      file.writeAsStringSync('test');
      await Future<void>.delayed(const Duration(seconds: 1));
      file.deleteSync();
      dir.deleteSync();
    },
  );
  test('Benchmark listing', () async {
    const trials = 100;
    final directory = Directory('.');
    final syncDuration = await _benchmark(trials, directory.listSync);
    final asyncDuration = await _benchmark(trials, () async {
      await directory.list().toList();
    });
    print('Sync: $syncDuration, async: $asyncDuration');
    expect(syncDuration, lessThan(asyncDuration));
  });
  test('Benchmark deleting', () async {
    const trials = 100;
    final directory = Directory('t_dir')..createSync();
    final syncDuration =
        await _benchmark(trials, directory.deleteSync, directory.createSync);
    final asyncDuration =
        await _benchmark(trials, directory.delete, directory.create);
    directory.deleteSync();
    print('Sync: $syncDuration, async: $asyncDuration');
    expect(syncDuration, lessThan(asyncDuration));
  });
  test('Benchmark exists', () async {
    const trials = 100;
    final directory = Directory('.');
    final syncDuration = await _benchmark(trials, directory.existsSync);
    final asyncDuration = await _benchmark(trials, directory.exists);
    print('Sync: $syncDuration, async: $asyncDuration');
    expect(syncDuration, lessThan(asyncDuration));
  });
}

Future<double> _benchmark(
  final int numTrial,
  final FutureOr<void> Function() action, [
  final FutureOr<void> Function()? cleanup,
]) async {
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < numTrial; i++) {
    await action();
    if (cleanup != null) {
      stopwatch.stop();
      await cleanup();
      stopwatch.start();
    }
  }
  return stopwatch.elapsed.inMicroseconds / numTrial;
}
