import 'package:fluent_ui/fluent_ui.dart';

Future<void> displayInfoBarInContext(
  BuildContext context, {
  required Widget title,
  Widget? content,
  InfoBarSeverity severity = InfoBarSeverity.info,
}) async {
  return await displayInfoBar(
    context,
    builder: (context, close) => InfoBar(
      title: title,
      content: content,
      severity: severity,
      onClose: close,
    ),
  );
}
