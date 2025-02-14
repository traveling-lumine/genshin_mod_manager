import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/entity/entries.dart';
import '../../app_version/data/github.dart';
import '../util/open_url.dart';

/// This route welcomes you!
class WelcomeRoute extends StatefulWidget {
  /// Creates a [WelcomeRoute].
  const WelcomeRoute({super.key});

  @override
  State<WelcomeRoute> createState() => _WelcomeRouteState();
}

class _WelcomeRouteState extends State<WelcomeRoute> {
  final _tapGestureRecognizer = TapGestureRecognizer();

  @override
  Widget build(final BuildContext context) => ScaffoldPage(
        header: const PageHeader(title: Text('Welcome')),
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (final context, final ref, final child) {
                  final game = ref.watch(
                    appConfigFacadeProvider.select(
                      (final value) => value.obtainValue(games).current!,
                    ),
                  );
                  return Text('Welcome to $game Mod Manager!');
                },
              ),
              const SizedBox(height: 16),
              const Text('This is a work in progress.'),
              const SizedBox(height: 16),
              const Text('Please report any issues to the GitHub repository.'),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  text: kRepoBase,
                  style: DefaultTextStyle.of(context).style.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                  recognizer: _tapGestureRecognizer,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer.onTap = () => openUrl(kRepoBase);
  }
}
