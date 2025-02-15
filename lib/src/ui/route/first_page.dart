import 'package:fluent_ui/fluent_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/usecase/add_game_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../widget/appbar.dart';

class FirstRoute extends ConsumerWidget {
  const FirstRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      NavigationView(
        appBar: getAppbar('Set the first game name'),
        content: ScaffoldPage.withPadding(
          header: const PageHeader(title: Text('Set the first game name')),
          content: _buildContent(ref),
        ),
      );

  Widget _buildContent(final WidgetRef ref) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('My game is...'),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: TextFormBox(
                placeholder: 'Game name',
                onFieldSubmitted: (final value) => _onGameAdd(ref, value),
              ),
            ),
          ],
        ),
      );

  void _onGameAdd(final WidgetRef ref, final String value) {
    final newConfig = addGameConfig(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      gameName: value,
    );
    ref.read(appConfigCProvider.notifier).setData(newConfig);
  }
}
