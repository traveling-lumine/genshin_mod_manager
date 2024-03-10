import 'package:flutter/foundation.dart';

abstract interface class HomeShellViewModel extends ChangeNotifier {}

HomeShellViewModel createViewModel() {
  return _HomeShellViewModelImpl();
}

class _HomeShellViewModelImpl extends ChangeNotifier
    implements HomeShellViewModel {}
