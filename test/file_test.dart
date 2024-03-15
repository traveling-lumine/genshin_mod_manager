import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Benchmark speed', () async {
    var stopwatch = Stopwatch()..start();
    const other = 10000;
    for (var i = 0; i < other; i++) {
      Directory('.').listSync();
    }
    final syncDuration = stopwatch.elapsed;
    stopwatch = Stopwatch()..start();
    for (var i = 0; i < other; i++) {
      await Directory('.').list().toList();
    }
    final asyncDuration = stopwatch.elapsed;
    expect(syncDuration, lessThan(asyncDuration));
  });
}
