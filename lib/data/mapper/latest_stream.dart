import 'package:genshin_mod_manager/domain/repo/latest_stream.dart';
import 'package:rxdart/streams.dart';

/// A converter to convert a [ValueStream] to a [LatestStream].
LatestStream<T> vS2LS<T extends Object>(final ValueStream<T> stream) =>
    _LatestStream(stream);

class _LatestStream<T extends Object> implements LatestStream<T> {
  _LatestStream(this.valueStream);

  @override
  Stream<T> get stream => valueStream;

  @override
  T? get latest => valueStream.valueOrNull;
  final ValueStream<T> valueStream;
}
