// ignore_for_file: avoid_slow_async_io, avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark listing', () async {
    var stopwatch = Stopwatch()..start();
    const other = 100;
    for (var i = 0; i < other; i++) {
      Directory('.').listSync();
    }
    final syncDuration = stopwatch.elapsed;
    stopwatch = Stopwatch()..start();
    for (var i = 0; i < other; i++) {
      await Directory('.').list().toList();
    }
    final asyncDuration = stopwatch.elapsed;
    print('Sync: ${syncDuration.inMicroseconds / other}'
        ', async: ${asyncDuration.inMicroseconds / other}');
    expect(syncDuration, lessThan(asyncDuration));
  });
  test('Benchmark deleting', () async {
    var stopwatch = Stopwatch()..start();
    const other = 100;
    final directory = Directory('t_dir');
    for (var i = 0; i < other; i++) {
      stopwatch.stop();
      directory.createSync();
      stopwatch.start();
      directory.deleteSync(recursive: true);
    }
    final syncDuration = stopwatch.elapsed;
    stopwatch = Stopwatch()..start();
    for (var i = 0; i < other; i++) {
      stopwatch.stop();
      await directory.create();
      stopwatch.start();
      await directory.delete(recursive: true);
    }
    final asyncDuration = stopwatch.elapsed;
    print('Sync: ${syncDuration.inMicroseconds / other}'
        ', async: ${asyncDuration.inMicroseconds / other}');
    expect(syncDuration, lessThan(asyncDuration));
  });
  test('Benchmark exists', () async {
    const other = 100;
    var stopwatch = Stopwatch()..start();
    for (var i = 0; i < other; i++) {
      Directory('.').existsSync();
    }
    final syncDuration = stopwatch.elapsed;
    stopwatch = Stopwatch()..start();
    for (var i = 0; i < other; i++) {
      await Directory('.').exists();
    }
    final asyncDuration = stopwatch.elapsed;
    print('Sync: ${syncDuration.inMicroseconds / other}'
        ', async: ${asyncDuration.inMicroseconds / other}');
    expect(syncDuration, lessThan(asyncDuration));
  });
}
