import 'package:collection/collection.dart';

extension SortNatural<T> on List<T> {
  List<T> sortNatural({required final String Function(T) by}) =>
      this..sort((final a, final b) => compareNatural(by(a), by(b)));
}
