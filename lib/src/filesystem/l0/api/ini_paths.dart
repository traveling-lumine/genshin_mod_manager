import '../entity/ini.dart';
import 'disposable.dart';

abstract interface class IniPaths implements Disposable {
  Stream<List<IniFile>> get iniPaths;
}
