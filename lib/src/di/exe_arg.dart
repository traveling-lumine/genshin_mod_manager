import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exe_arg.g.dart';

@riverpod
class ArgProvider extends _$ArgProvider {
  static List<String> initial = [];
  late final StreamController<String> _controller;

  @override
  Stream<String> build() {
    final controller = StreamController<String>();
    ref.onDispose(controller.close);
    _controller = controller;

    initial.forEach(controller.add);
    initial = [];

    return controller.stream;
  }

  void add(final String arg) {
    _controller.add(arg);
  }
}

enum AcceptedArg {
  run3dm('/run3dm'),
  rungame('/rungame'),
  runboth('/runboth');

  const AcceptedArg(this.cmd);

  final String cmd;
}
