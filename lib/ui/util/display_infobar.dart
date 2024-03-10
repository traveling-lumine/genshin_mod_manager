import 'package:fluent_ui/fluent_ui.dart';

Future<void> displayInfoBarInContext(
  BuildContext context, {
  required Widget title,
  Duration duration = const Duration(seconds: 3),
  Widget? content,
  Widget? action,
  InfoBarSeverity severity = InfoBarSeverity.info,
}) {
  return displayInfoBar(
    context,
    duration: duration,
    builder: (context, close) => InfoBar(
      title: title,
      content: content,
      action: action,
      severity: severity,
      onClose: close,
    ),
  );
}
