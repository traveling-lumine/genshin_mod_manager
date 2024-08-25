import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage.dart';

part 'games_list.g.dart';

@riverpod
class GamesList extends _$GamesList {
  @override
  List<String> build() {
    final storage = ref.watch(sharedPreferenceStorageProvider);
    final gamesList = storage.getList('games') ?? [];
    return gamesList;
  }

  void addGame(final String game) {
    final storage = ref.read(sharedPreferenceStorageProvider);
    if (state.contains(game)) {
      return;
    }
    final newGamesList = [...state, game];
    storage.setList('games', newGamesList);
    state = newGamesList;
  }

  void removeGame(final String game) {
    final storage = ref.read(sharedPreferenceStorageProvider);
    if (!state.contains(game)) {
      return;
    }
    final newGamesList = state.where((final e) => e != game).toList();
    storage.setList('games', newGamesList);
    state = newGamesList;
  }
}
