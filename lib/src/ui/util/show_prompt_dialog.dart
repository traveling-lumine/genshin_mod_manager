import 'package:fluent_ui/fluent_ui.dart';

Future<bool> showPromptDialog({
  required final BuildContext context,
  required final String title,
  required final Widget content,
  required final String confirmButtonLabel,
  final String cancelButtonLabel = 'Cancel',
  final bool redButton = false,
}) async {
  final userResponse = await showDialog<bool?>(
    context: context,
    builder: (final dCtx) {
      final filledButton = FilledButton(
        onPressed: () => Navigator.of(dCtx).pop(true),
        child: Text(confirmButtonLabel),
      );
      return ContentDialog(
        title: Text(title),
        content: content,
        actions: [
          Button(
            onPressed: Navigator.of(dCtx).pop,
            child: Text(cancelButtonLabel),
          ),
          if (redButton)
            FluentTheme(
              data: FluentTheme.of(dCtx).copyWith(accentColor: Colors.red),
              child: filledButton,
            )
          else
            filledButton,
        ],
      );
    },
  );
  return userResponse ?? false;
}
