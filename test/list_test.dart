import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Unmodifiable List View and List.unmodifiable', () {
    final list = [1, 2, 3];
    final unmodifiable = List.unmodifiable(list).cast<int>();
    final view = UnmodifiableListView(list);
    print(list.runtimeType);
    print(unmodifiable.runtimeType);
    print(view.runtimeType);
    expect(unmodifiable, list);
    expect(unmodifiable, isA<List<int>>());
    expect(unmodifiable, isA<UnmodifiableListView<int>>());
  });
}
