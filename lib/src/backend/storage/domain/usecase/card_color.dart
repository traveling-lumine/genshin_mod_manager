import 'package:fluent_ui/fluent_ui.dart';
import '../persistent_storage.dart';

Color initializeCardColorUseCase(
  final PersistentStorage repository, {
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey =
      getCardColorAccessKeyUseCase(isBright: isBright, isEnabled: isEnabled);
  final color = repository.getInt(accessKey);
  if (color == null) {
    final defaultValue =
        getDefaultValueUseCase(isBright: isBright, isEnabled: isEnabled);
    repository.setInt(accessKey, defaultValue.value);
    return defaultValue;
  }
  return Color(color);
}

String getCardColorAccessKeyUseCase({
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey = switch ((isBright, isEnabled)) {
    (true, true) => 'cardColorBrightEnabled',
    (true, false) => 'cardColorBrightDisabled',
    (false, true) => 'cardColorDarkEnabled',
    (false, false) => 'cardColorDarkDisabled',
  };
  return accessKey;
}

void setCardColorUseCase(
  final PersistentStorage repository,
  final Color color, {
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey = getCardColorAccessKeyUseCase(
    isBright: isBright,
    isEnabled: isEnabled,
  );
  repository.setInt(accessKey, color.value);
}

Color getDefaultValueUseCase({
  required final bool isBright,
  required final bool isEnabled,
}) =>
    switch ((isBright, isEnabled)) {
      (true, true) => Colors.green.lightest,
      (true, false) => Colors.red.lightest.withOpacity(0.5),
      (false, true) => Colors.green.darkest.withOpacity(0.8),
      (false, false) => Colors.red.darkest.withOpacity(0.6),
    };
