import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../di/app_state/games_list.dart';
import '../constants.dart';
import '../widget/appbar.dart';

class FirstRoute extends ConsumerWidget {
  const FirstRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
      gamesListProvider,
      (final previous, final next) {
        if (next.isNotEmpty) {
          context.go(RouteNames.home.name);
        }
      },
    );
    return NavigationView(
      appBar: getAppbar('Set the first game name'),
      content: ScaffoldPage.withPadding(
        header: const PageHeader(
          title: Text('Set the first game name'),
        ),
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('My game is...'),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: TextFormBox(
                  placeholder: 'Game name',
                  onFieldSubmitted: (final value) {
                    ref.read(gamesListProvider.notifier).addGame(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
