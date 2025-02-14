import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_config/l1/entity/entries.dart';
import '../../app_config/l1/entity/game_config.dart';
import '../constants.dart';
import '../widget/appbar.dart';

class FirstRoute extends ConsumerWidget {
  const FirstRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
        appConfigFacadeProvider.select(
          (final value) => value.obtainValue(games).gameConfig.keys.toList(),
        ), (final previous, final next) {
      if (next.isNotEmpty) {
        context.goNamed(RouteNames.home.name);
      }
    });
    return NavigationView(
      appBar: getAppbar('Set the first game name'),
      content: ScaffoldPage.withPadding(
        header: const PageHeader(title: Text('Set the first game name')),
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
                    final newGameConfig = GameConfigMediator(
                      current: value,
                      gameConfig: {value: const GameConfig()},
                    );
                    final newConfig =
                        changeAppConfigUseCase<GameConfigMediator>(
                      appConfigFacade: ref.read(appConfigFacadeProvider),
                      appConfigPersistentRepo:
                          ref.read(appConfigPersistentRepoProvider),
                      entry: games,
                      value: newGameConfig,
                    );
                    ref.read(appConfigCProvider.notifier).update(newConfig);
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
