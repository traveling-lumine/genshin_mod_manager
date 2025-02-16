import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l1/di/categories.dart';
import '../constants.dart';

class CategoryProviderWidget extends ConsumerWidget {
  const CategoryProviderWidget({
    required this.builder,
    required this.categoryName,
    super.key,
  });
  final Widget Function(ModCategory category) builder;
  final String categoryName;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(categoriesProvider, (final previous, final next) {
      final isIn = next.requireValue.any((final e) => e.name == categoryName);
      if (!isIn) {
        context.goNamed(RouteNames.home.name);
      }
    });
    final category = ref
        .watch(categoriesProvider)
        .requireValue
        .firstWhere((final e) => e.name == categoryName);
    return builder(category);
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<Widget Function(ModCategory category)>.has(
          'builder',
          builder,
        ),
      )
      ..add(StringProperty('categoryName', categoryName));
  }
}
