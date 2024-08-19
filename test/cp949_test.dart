import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cp949', () {
    const text = 'ÇÑ±¹¾îÀÎÄÚµù';
    final dec = cp949.decodeString(text);
    print(dec);
    expect(text, equals(cp949.encodeToString(dec)));
  });
}
