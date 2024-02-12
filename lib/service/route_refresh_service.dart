import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';

class RouteRefreshService extends ChangeNotifier {
  String? _destination;

  String? get destination => _destination;

  void refresh(String destination) {
    _destination = destination;
    // postframe prevents rebuild while build error
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void clear() {
    _destination = null;
  }
}
