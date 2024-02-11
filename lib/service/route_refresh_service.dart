import 'package:fluent_ui/fluent_ui.dart';

class RouteRefreshService extends ChangeNotifier {
  String? _destination;

  String? get destination => _destination;

  void refresh(String destination) {
    _destination = destination;
    notifyListeners();
    _destination = null;
  }
}
