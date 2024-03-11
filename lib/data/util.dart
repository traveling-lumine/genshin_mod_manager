import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/streams.dart';

LatestStream<T> vS2LS<T>(ValueStream<T> stream) {
  return _Wrapper(stream);
}

class _Wrapper<T> implements LatestStream<T> {
  @override
  final ValueStream<T> stream;

  _Wrapper(this.stream);

  @override
  T get latest => stream.value;
}
