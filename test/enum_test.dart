import 'package:flutter_test/flutter_test.dart';

enum Aa {
  a,
  b,
  c;

  String get name => '/${(this as Enum).name}';
}

void main() {
  test('enum test', () {
    expect(Aa.a.name, '/a');
    expect(Aa.b.name, '/b');
    expect(Aa.c.name, '/c');
  });
}
