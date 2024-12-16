import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/di/current_target_game.dart';
import '../../storage/di/games_list.dart';
import '../util/display_infobar.dart';

/// Game selector widget.
class GameSelector extends HookConsumerWidget {
  /// Creates a [GameSelector].
  const GameSelector({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(targetGameProvider);
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
              .watch(gamesListProvider)
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
              unawaited(
                displayInfoBarInContext(
                  context,
                  title: const Text('Whaat?'),
                  severity: InfoBarSeverity.error,
                  content: const Text(
                    'Null value. This is a bug. Please report.',
                  ),
                ),
              );
              return;
            }
            ref.read(targetGameProvider.notifier).setValue(value);
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
                final games = ref.read(gamesListProvider);
                if (games.contains(value)) {
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
                final games = ref.read(gamesListProvider);
                final text = controller.text;
                if (games.contains(text)) {
                  return;
                }
                Navigator.of(dCtx).pop();
                controller.clear();
                ref.read(gamesListProvider.notifier).addGame(text);
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
                  ref.read(gamesListProvider.notifier).removeGame(value);
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
