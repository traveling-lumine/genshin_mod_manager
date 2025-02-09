import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'games_list.dart';
import 'storage.dart';

part 'current_target_game.g.dart';

@riverpod
class TargetGame extends _$TargetGame {
  @override
  String build() {
    final storage = ref.watch(persistentRepoProvider).requireValue;
    final gamesList = ref.watch(gamesListProvider);
    final lastGame = storage.getString('lastGame');
    if (gamesList.contains(lastGame)) {
      return lastGame!;
    } else {
      final first = gamesList.first;
      storage.setString('lastGame', first);
      return first;
    }
  }

  void setValue(final String value) {
    final read = ref.read(persistentRepoProvider).requireValue;
    final gamesList = ref.read(gamesListProvider);
    if (!gamesList.contains(value)) {
      return;
    }
    read.setString('lastGame', value);
    state = value;
  }
}
