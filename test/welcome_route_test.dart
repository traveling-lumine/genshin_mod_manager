import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/route/welcome.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mock/mock_url_launcher_platform.dart';

void main() {
  late MockUrlLauncher mock;
  setUp(() {
    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets('WelcomeRoute welcomes you', (WidgetTester tester) async {
    await tester.pumpWidget(const FluentApp(home: WelcomeRoute()));

    expect(find.text('Welcome'), findsAny);
  });
  testWidgets('WelcomeRoute has a link to GitHub', (WidgetTester tester) async {
    await tester.pumpWidget(const FluentApp(home: WelcomeRoute()));

    expect(find.text('Welcome'), findsAny);

    mock
      ..setLaunchExpectations(
        url: 'https://github.com/traveling-lumine/genshin_mod_manager',
        launchMode: PreferredLaunchMode.platformDefault,
        enableJavaScript: true,
        enableDomStorage: true,
        universalLinksOnly: false,
        headers: <String, String>{},
        webOnlyWindowName: null,
      )
      ..setResponse(true);

    await tester.tap(find.textContaining("http", findRichText: true));
    expect(mock.launchCalled, true);
  });
}
