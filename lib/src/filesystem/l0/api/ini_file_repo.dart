import '../entity/ini.dart';
import 'disposable.dart';

abstract interface class IniFileRepo implements Disposable {
  Stream<List<IniStatement>> get statements;

  Future<void> edit({
    required final int lineNum,
    required final String value,
  });
}
