import 'package:flutter/rendering.dart';

abstract class CrossAxisAwareDelegate extends SliverGridDelegate {
  /// The latest number of cross axis count calculated by the delegate.
  int? get latestCrossAxisCount;
}
