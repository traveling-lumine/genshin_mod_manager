import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeRoute extends StatelessWidget {
  const WelcomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    const repo = 'https://github.com/traveling-lumine/genshin_mod_manager';
    return ScaffoldPage(
      header: const PageHeader(title: Text('Welcome')),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Welcome to Genshin Mod Manager!'),
            const SizedBox(height: 16),
            const Text('This is a work in progress.'),
            const SizedBox(height: 16),
            const Text('Please report any issues to the GitHub repository.'),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                text: repo,
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchUrl(Uri.parse(repo)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
