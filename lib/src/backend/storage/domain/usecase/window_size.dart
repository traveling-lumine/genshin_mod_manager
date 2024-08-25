import 'dart:ui';

import '../persistent_storage.dart';

Size? initializeWindowSizeUseCase(final PersistentStorage watch) {
  try {
    final width = double.parse(watch.getString('windowWidth') ?? '');
    final height = double.parse(watch.getString('windowHeight') ?? '');
    return Size(width, height);
  } on Exception {
    return null;
  }
}

void setWindowSizeUseCase(final PersistentStorage read, final Size value) {
  read
    ..setString('windowWidth', value.width.toString())
    ..setString('windowHeight', value.height.toString());
}
