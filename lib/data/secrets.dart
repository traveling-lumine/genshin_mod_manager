import 'package:envied/envied.dart';

part 'secrets.g.dart';

// ignore: avoid_classes_with_only_static_members
@Envied(obfuscate: true)
abstract class Env {
  @EnviedField()
  static final String val1 = _Env.val1;
  @EnviedField()
  static final String val2 = _Env.val2;
  @EnviedField()
  static final String val3 = _Env.val3;
  @EnviedField()
  static final String val4 = _Env.val4;
  @EnviedField()
  static final String val5 = _Env.val5;
  @EnviedField()
  static final String val6 = _Env.val6;
  @EnviedField()
  static final String val7 = _Env.val7;
  @EnviedField()
  static final String val8 = _Env.val8;
  @EnviedField()
  static final String val9 = _Env.val9;
  @EnviedField()
  static final String val10 = _Env.val10;
  @EnviedField()
  static final String val11 = _Env.val11;
  @EnviedField()
  static final String val12 = _Env.val12;
}
