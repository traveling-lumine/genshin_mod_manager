// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/route/welcome.dart';

void main() {
  testWidgets('MyWidget has a title and message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FluentApp(home: WelcomeRoute()));

    // Verify that our counter starts at 0.
    expect(find.text('Welcome'), findsOneWidget);
  });
}
