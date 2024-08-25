import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/di/app_state.dart';
import 'package:genshin_mod_manager/src/ui/route/welcome.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mock/mock_url_launcher_platform.dart';

part 'welcome_route_test.g.dart';

void main() {
  late MockUrlLauncher mock;
  setUp(() {
    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets('WelcomeRoute welcomes you', (final tester) async {
    await pumpMainWidget(tester);

    expect(find.text('Welcome'), findsAny);
  });
  testWidgets('WelcomeRoute has a link to GitHub', (final tester) async {
    await pumpMainWidget(tester);

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
      ..response = true;

    await tester.tap(find.textContaining('http', findRichText: true));
    expect(mock.launchCalled, true);
  });
}

@riverpod
class MockTargetGame extends _$MockTargetGame implements TargetGame {
  @override
  String build() => 'test';

  @override
  void setValue(final String value) {
    // pass
  }
}

Future<void> pumpMainWidget(final WidgetTester tester) => tester.pumpWidget(
      ProviderScope(
        overrides: [targetGameProvider.overrideWith(MockTargetGame.new)],
        child: const FluentApp(home: WelcomeRoute()),
      ),
    );
