import 'package:fluent_ui/fluent_ui.dart';

class WelcomeRoute extends StatelessWidget {
  const WelcomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      header: PageHeader(title: Text('Welcome')),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome to Genshin Mod Manager!'),
            SizedBox(height: 16),
            Text('This is a work in progress.'),
            SizedBox(height: 16),
            Text('Please report any issues to the GitHub repository.'),
          ],
        ),
      ),
    );
  }
}
