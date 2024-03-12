import 'package:collection/collection.dart';
import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/streams.dart';

LatestStream<T> vS2LS<T>(ValueStream<T> stream) {
  return _LatestStream(stream);
}

class _LatestStream<T> implements LatestStream<T> {
  static const _equality = DeepCollectionEquality();
  @override
  final Stream<T> stream;

  @override
  T get latest => valueStream.value;
  final ValueStream<T> valueStream;

  _LatestStream(this.valueStream)
      : stream = valueStream.distinct(_equality.equals);
}
