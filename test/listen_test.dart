import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Run it!", () async {
    print(Directory('tdir').absolute);
    Directory('tdir').watch().listen(print);
    await Future.delayed(const Duration(seconds: 10222));
  });
}
