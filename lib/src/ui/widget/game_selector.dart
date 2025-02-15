import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import '../../app_config/l0/entity/game_config.dart';

/// Game selector widget.
class GameSelector extends HookConsumerWidget {
  /// Creates a [GameSelector].
  const GameSelector({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(games).current!),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(),
        const SizedBox(width: 8),
        _buildComboBox(ref, context, value),
      ],
    );
  }

  Widget _buildButton() {
    final controller = useTextEditingController();
    return RepaintBoundary(
      child: Consumer(
        builder: (final context, final ref, final child) => IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            _onGameAdd(context, controller, ref);
          },
        ),
      ),
    );
  }

  Widget _buildComboBox(
    final WidgetRef ref,
    final BuildContext context,
    final String value,
  ) =>
      RepaintBoundary(
        child: ComboBox<String>(
          items: ref
              .watch(
                appConfigFacadeProvider.select(
                  (final value) =>
                      value.obtainValue(games).gameConfig.keys.toList(),
                ),
              )
              .map(
                (final e) => ComboBoxItem<String>(
                  value: e,
                  child: GestureDetector(
                    onLongPress: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      _onGameDelete(
                        context,
                        TextEditingController(),
                        ref,
                        e,
                      );
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 50,
                        maxWidth: 200,
                      ),
                      child: Text(e),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (final value) {
            if (value == null) {
              return;
            }
            final currentGameConfig =
                ref.read(appConfigFacadeProvider).obtainValue(games);
            if (!currentGameConfig.gameConfig.containsKey(value)) {
              return;
            }
            final newGameConfig = GameConfigMediator(
              current: value,
              gameConfig: currentGameConfig.gameConfig,
            );
            final newConfig = changeAppConfigUseCase<GameConfigMediator>(
              appConfigFacade: ref.read(appConfigFacadeProvider),
              appConfigPersistentRepo:
                  ref.read(appConfigPersistentRepoProvider),
              entry: games,
              value: newGameConfig,
            );
            ref.read(appConfigCProvider.notifier).setData(newConfig);
          },
          value: value,
        ),
      );

  void _onGameAdd(
    final BuildContext context,
    final TextEditingController controller,
    final WidgetRef ref,
  ) {
    unawaited(
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (final dCtx) => ContentDialog(
          title: const Text('Add Game'),
          content: IntrinsicHeight(
            child: TextFormBox(
              autovalidateMode: AutovalidateMode.always,
              controller: controller,
              placeholder: 'Game Name',
              validator: (final value) {
                final gameList = ref
                    .read(appConfigFacadeProvider)
                    .obtainValue(games)
                    .gameConfig
                    .keys;
                if (gameList.contains(value)) {
                  return 'Game already exists';
                }
                return null;
              },
            ),
          ),
          actions: [
            Button(
              onPressed: Navigator.of(dCtx).pop,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final obtainValue =
                    ref.read(appConfigFacadeProvider).obtainValue(games);
                final gameList = obtainValue.gameConfig.keys;
                final text = controller.text;
                if (gameList.contains(text)) {
                  return;
                }
                Navigator.of(dCtx).pop();
                controller.clear();
                final newGameConfig = obtainValue.copyWith(
                  current: text,
                  gameConfig: {
                    ...obtainValue.gameConfig,
                    text: const GameConfig(),
                  },
                );
                final newConfig = changeAppConfigUseCase<GameConfigMediator>(
                  appConfigFacade: ref.read(appConfigFacadeProvider),
                  appConfigPersistentRepo:
                      ref.read(appConfigPersistentRepoProvider),
                  entry: games,
                  value: newGameConfig,
                );
                ref.read(appConfigCProvider.notifier).setData(newConfig);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _onGameDelete(
    final BuildContext context,
    final TextEditingController controller,
    final WidgetRef ref,
    final String value,
  ) {
    unawaited(
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (final dCtx) => ContentDialog(
          title: Text('Delete Game $value?'),
          actions: [
            Button(
              onPressed: Navigator.of(dCtx).pop,
              child: const Text('Cancel'),
            ),
            FluentTheme(
              data: FluentThemeData(accentColor: Colors.red),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dCtx).pop();
                  controller.clear();
                  final currentGameConfig =
                      ref.read(appConfigFacadeProvider).obtainValue(games);
                  if (!currentGameConfig.gameConfig.containsKey(value)) {
                    return;
                  }
                  final map = {
                    ...currentGameConfig.gameConfig,
                  }..remove(value);
                  final current = value == currentGameConfig.current
                      ? (map.keys.isNotEmpty ? map.keys.first : null)
                      : currentGameConfig.current;
                  final newGameConfig = GameConfigMediator(
                    current: current,
                    gameConfig: map,
                  );
                  final newConfig = changeAppConfigUseCase<GameConfigMediator>(
                    appConfigFacade: ref.read(appConfigFacadeProvider),
                    appConfigPersistentRepo:
                        ref.read(appConfigPersistentRepoProvider),
                    entry: games,
                    value: newGameConfig,
                  );
                  ref.read(appConfigCProvider.notifier).setData(newConfig);
                },
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
