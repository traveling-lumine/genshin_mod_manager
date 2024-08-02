import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exe_arg.g.dart';

@riverpod
class ArgProvider extends _$ArgProvider {
  static late List<String> initial;

  @override
  List<String> build() {
    ref.onDispose(clear);
    return initial;
  }

  void clear() {
    final value = <String>[];
    initial = value;
    state = value;
  }
}

enum AcceptedArg {
  run3dm('/run3dm'),
  rungame('/rungame'),
  runboth('/runboth');

  const AcceptedArg(this.cmd);

  final String cmd;
}
