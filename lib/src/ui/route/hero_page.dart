import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import '../widget/mod_preview_image.dart';

Page<dynamic> heroPage(
  final BuildContext context,
  final String heroTag,
) =>
    CustomTransitionPage(
      barrierDismissible: true,
      opaque: false,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (
        final context,
        final animation,
        final secondaryAnimation,
        final child,
      ) =>
          AnimatedBuilder(
        animation: animation,
        builder: (final context, final child) {
          const mult = 6;
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: animation.value * mult,
              sigmaY: animation.value * mult,
            ),
            child: child,
          );
        },
        child: child,
      ),
      child: GestureDetector(
        onTap: context.pop,
        onSecondaryTap: context.pop,
        child: Hero(tag: heroTag, child: ModPreviewImage(path: heroTag)),
      ),
    );
