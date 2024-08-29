import 'dart:ui';

import '../repo/persistent_storage.dart';

Size? initializeWindowSizeUseCase(final PersistentStorage? watch) {
  try {
    final width = double.parse(watch?.getString('windowWidth') ?? '');
    final height = double.parse(watch?.getString('windowHeight') ?? '');
    return Size(width, height);
  } on Exception {
    return null;
  }
}

void setWindowSizeUseCase(final PersistentStorage? read, final Size value) {
  read?.setString('windowWidth', value.width.toString());
  read?.setString('windowHeight', value.height.toString());
}
