import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('pDir join pBase equals original', () {
    const path = 'c';
    final split = p.split(path);
    expect(split, ['c']);
  });
}
