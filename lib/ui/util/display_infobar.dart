import 'package:fluent_ui/fluent_ui.dart';

Future<void> displayInfoBarInContext(
  final BuildContext context, {
  required final Widget title,
  final Duration duration = const Duration(seconds: 3),
  final Widget? content,
  final Widget? action,
  final InfoBarSeverity severity = InfoBarSeverity.info,
}) =>
    displayInfoBar(
      context,
      duration: duration,
      builder: (final context, final close) => InfoBar(
        title: title,
        content: content,
        action: action,
        severity: severity,
        onClose: close,
      ),
    );
