// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'cross_axis_aware_delegate.dart';

/// Creates grid layouts with a fixed number of tiles in the cross axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with equally sized and spaced tiles.
///
/// {@tool dartpad}
/// Here is an example using the [childAspectRatio] property. On a device with a
/// screen width of 800.0, it creates a GridView with each tile with a width of
/// 200.0 and a height of 100.0.
///
/// ** See code in examples/api/lib/rendering/sliver_grid/sliver_grid_delegate_with_fixed_cross_axis_count.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// Here is an example using the [mainAxisExtent] property. On a device with a
/// screen width of 800.0, it creates a GridView with each tile with a width of
/// 200.0 and a height of 150.0.
///
/// ** See code in examples/api/lib/rendering/sliver_grid/sliver_grid_delegate_with_fixed_cross_axis_count.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * [SliverGridDelegateWithMaxCrossAxisExtent], which creates a layout with
///    tiles that have a maximum cross-axis extent.
///  * [SliverGridDelegate], which creates arbitrary layouts.
///  * [GridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverGridDelegateWithFixedCrossAxisCount extends CrossAxisAwareDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// The `mainAxisSpacing`, `mainAxisExtent` and `crossAxisSpacing` arguments
  /// must not be negative. The `crossAxisCount` and `childAspectRatio`
  /// arguments must be greater than zero.
  SliverGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
  })  : assert(crossAxisCount > 0),
        assert(mainAxisSpacing >= 0),
        assert(crossAxisSpacing >= 0),
        assert(childAspectRatio > 0),
        assert(mainAxisExtent == null || mainAxisExtent >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  @override
  int? get latestCrossAxisCount => crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The extent of each tile in the main axis. If provided it would define the
  /// logical pixels taken by each tile in the main-axis.
  ///
  /// If null, [childAspectRatio] is used instead.
  final double? mainAxisExtent;

  bool _debugAssertIsValid() {
    assert(crossAxisCount > 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent =
        mainAxisExtent ?? childCrossAxisExtent / childAspectRatio;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedCrossAxisCount oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
  }
}
