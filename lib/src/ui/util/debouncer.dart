import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer(this.duration);
  final Duration duration;
  Timer? _timer;

  void call(final VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}
