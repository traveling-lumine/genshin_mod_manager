import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Run it!", () async {
    print(Directory('.').absolute);
    Directory('.').watch(recursive: true).listen(print);
    await Future.delayed(const Duration(seconds: 10222));
  });
}
