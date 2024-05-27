import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/domain/entity/game_enum.dart';
import 'package:genshin_mod_manager/flow/app_state.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Game selector widget.
class GameSelector extends ConsumerWidget {
  /// Creates a [GameSelector].
  const GameSelector({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final value = ref.watch(targetGameProvider);
    return RepaintBoundary(
      child: ComboBox<TargetGames>(
        items: TargetGames.values
            .map(
              (final e) => ComboBoxItem<TargetGames>(
                value: e,
                child: Text(e.displayName),
              ),
            )
            .toList(),
        onChanged: (final value) {
          if (value == null) {
            unawaited(
              displayInfoBarInContext(
                context,
                title: const Text("Whaat?"),
                severity: InfoBarSeverity.error,
                content: const Text(
                  "Null value. This is a bug. Please report.",
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
  }
}
