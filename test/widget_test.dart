// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

void main() {
  try {
    dynamic a = jsonDecode('{"a": 1}');
    final b = Map<String, Map<String, List<String>>>.from(a);
    print(b);
  } on TypeError catch (e) {
    print(e);
    print(e.runtimeType);
  }
}
