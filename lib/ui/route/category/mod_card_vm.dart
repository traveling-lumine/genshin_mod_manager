import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class ModCardViewModel implements BaseViewModel {}

ModCardViewModel createModCardViewModel() => _ModCardViewModelImpl();

class _ModCardViewModelImpl extends ChangeNotifier
    implements ModCardViewModel {}
