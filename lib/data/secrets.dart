import 'package:envied/envied.dart';

part 'secrets.g.dart';

// ignore: avoid_classes_with_only_static_members
@Envied(obfuscate: true)
abstract class Env {
  @EnviedField()
  static final String kAkashaBase = _Env.kAkashaBase;
  @EnviedField()
  static final String kAkashaDownload = _Env.kAkashaDownload;
  @EnviedField()
  static final String kAkashaList = _Env.kAkashaList;
  @EnviedField()
  static final String secretHeader = _Env.secretHeader;
  @EnviedField()
  static final String secret = _Env.secret;
  @EnviedField()
  static final String pwBody = _Env.pwBody;
}
