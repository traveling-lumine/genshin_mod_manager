import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';

class RedFilledButton extends Button {
  /// Creates a filled button
  const RedFilledButton({
    super.key,
    required super.child,
    required super.onPressed,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.focusNode,
    super.autofocus = false,
    super.style,
    super.focusable = true,
  });

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final buttonTheme = ButtonTheme.of(context);
    return buttonTheme.filledButtonStyle;
  }

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    final def = ButtonStyle(
      backgroundColor: ButtonState.resolveWith((states) {
        return backgroundColor(theme, states);
      }),
      foregroundColor: ButtonState.resolveWith((states) {
        return foregroundColor(theme, states);
      }),
      shape: ButtonState.resolveWith((states) {
        return shapeBorder(theme, states);
      }),
    );

    return super.defaultStyleOf(context).merge(def) ?? def;
  }

  static Color backgroundColor(
    FluentThemeData theme,
    Set<ButtonStates> states,
  ) {
    Color res;
    if (states.isDisabled) {
      res = theme.resources.accentFillColorDisabled;
    } else if (states.isPressing) {
      res = theme.accentColor.tertiaryBrushFor(theme.brightness);
    } else if (states.isHovering) {
      res = theme.accentColor.secondaryBrushFor(theme.brightness);
    } else {
      res = theme.accentColor.defaultBrushFor(theme.brightness);
    }
    res = Color.fromARGB(
      res.alpha,
      160,
      0,
      0,
    );
    return res;
  }

  static Color foregroundColor(
      FluentThemeData theme, Set<ButtonStates> states) {
    final res = theme.resources;
    if (states.isPressing) {
      return res.textOnAccentFillColorSecondary;
    } else if (states.isHovering) {
      return res.textOnAccentFillColorPrimary;
    } else if (states.isDisabled) {
      return res.textOnAccentFillColorDisabled;
    }
    return res.textOnAccentFillColorPrimary;
  }

  static ShapeBorder shapeBorder(
      FluentThemeData theme, Set<ButtonStates> states) {
    return states.isPressing || states.isDisabled
        ? RoundedRectangleBorder(
            side: BorderSide(
              color: theme.resources.controlFillColorTransparent,
            ),
            borderRadius: BorderRadius.circular(4.0),
          )
        : RoundedRectangleGradientBorder(
            gradient: LinearGradient(
              begin: const Alignment(0.0, -2),
              end: Alignment.bottomCenter,
              colors: [
                theme.resources.controlStrokeColorOnAccentSecondary,
                theme.resources.controlStrokeColorOnAccentDefault,
              ],
              stops: const [0.33, 1.0],
              transform: const GradientRotation(pi),
            ),
            borderRadius: BorderRadius.circular(4.0),
          );
  }
}
