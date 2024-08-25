import 'package:riverpod_annotation/riverpod_annotation.dart';

/// The notifier for boolean value.
abstract interface class ValueSettable<T> implements AutoDisposeNotifier<T> {
  /// Sets the value.
  void setValue(final T value);
}
