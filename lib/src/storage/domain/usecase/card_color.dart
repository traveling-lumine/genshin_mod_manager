import 'package:fluent_ui/fluent_ui.dart';
import '../constants.dart';
import '../repo/persistent_storage.dart';

Color initializeCardColorUseCase(
  final PersistentStorage? repository, {
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey =
      _getCardColorAccessKeyUseCase(isBright: isBright, isEnabled: isEnabled);
  final color = repository?.getInt(accessKey);
  if (color == null) {
    final defaultValue =
        getDefaultValueUseCase(isBright: isBright, isEnabled: isEnabled);
    repository?.setInt(accessKey, defaultValue.value);
    return defaultValue;
  }
  return Color(color);
}

void setCardColorUseCase(
  final PersistentStorage? repository,
  final Color color, {
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey =
      _getCardColorAccessKeyUseCase(isBright: isBright, isEnabled: isEnabled);
  repository?.setInt(accessKey, color.value);
}

Color getDefaultValueUseCase({
  required final bool isBright,
  required final bool isEnabled,
}) =>
    switch ((isBright, isEnabled)) {
      (true, true) => Colors.green.lightest,
      (true, false) => Colors.red.lightest.withValues(alpha: 0.5),
      (false, true) => Colors.green.darkest.withValues(alpha: 0.8),
      (false, false) => Colors.red.darkest.withValues(alpha: 0.6),
    };

String _getCardColorAccessKeyUseCase({
  required final bool isBright,
  required final bool isEnabled,
}) {
  final accessKey = switch ((isBright, isEnabled)) {
    (true, true) => StorageAccessKey.cardColorBrightEnabled.name,
    (true, false) => StorageAccessKey.cardColorBrightDisabled.name,
    (false, true) => StorageAccessKey.cardColorDarkEnabled.name,
    (false, false) => StorageAccessKey.cardColorDarkDisabled.name,
  };
  return accessKey;
}
