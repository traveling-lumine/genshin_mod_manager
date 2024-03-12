/// A class that holds the latest value of a stream and the stream itself.
/// An abstraction of ValueStream but avoiding the need to import rxdart.
/// The stream itself is distinct (no consecutive same value).
/// The equality for distinct should be deep.
///
/// Not sure this is a good idea.
abstract interface class LatestStream<T> {
  T get latest;

  Stream<T> get stream;
}
