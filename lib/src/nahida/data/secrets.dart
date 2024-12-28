import 'package:envied/envied.dart';

part 'secrets.g.dart';

// Since this package works this way
// ignore: avoid_classes_with_only_static_members
@Envied(obfuscate: true)
abstract class Env {
  @EnviedField()
  static final String val8 = _Env.val8;
  @EnviedField()
  static final String val9 = _Env.val9;
  @EnviedField()
  static final String val14 = _Env.val14;
}
