import 'dart:ui';

import '../api/persistent_storage.dart';
import '../constants.dart';

final windowWidthKey = StorageAccessKey.windowWidth.name;
final windowHeightKey = StorageAccessKey.windowHeight.name;

Size? initializeWindowSizeUseCase(final PersistentStorage? watch) {
  try {
    final width = double.parse(watch?.getString(windowWidthKey) ?? '');
    final height = double.parse(
      watch?.getString(windowHeightKey) ?? '',
    );
    return Size(width, height);
  } on Exception {
    return null;
  }
}

void setWindowSizeUseCase(final PersistentStorage? read, final Size value) {
  read?.setString(windowWidthKey, value.width.toString());
  read?.setString(windowHeightKey, value.height.toString());
}
