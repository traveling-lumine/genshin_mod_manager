import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/usecase/card_color.dart';
import 'storage.dart';

part 'card_color.g.dart';

@riverpod
class CardColor extends _$CardColor {
  @override
  Color build({required final bool isBright, required final bool isEnabled}) {
    final repository = ref.watch(persistentStorageProvider).valueOrNull;
    final color = initializeCardColorUseCase(
      repository,
      isBright: isBright,
      isEnabled: isEnabled,
    );
    return color;
  }

  void setColor(final Color color) {
    final repository = ref.read(persistentStorageProvider).valueOrNull;
    setCardColorUseCase(
      repository,
      color,
      isBright: isBright,
      isEnabled: isEnabled,
    );
    state = color;
  }
}
