import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/expander.dart';

class SettingElement extends StatelessWidget {
  const SettingElement({
    required this.text,
    this.initiallyExpanded = false,
    super.key,
    this.subTitle,
    this.content,
    this.leading,
    this.trailing,
  });

  final String text;
  final bool initiallyExpanded;
  final Widget? subTitle;
  final Widget? content;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.all(2),
        child: Expander2(
          initiallyExpanded: initiallyExpanded,
          header: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: ListTile(
              leading: leading,
              title: Text(text),
              subtitle: subTitle,
            ),
          ),
          trailing: trailing,
          content: content,
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(DiagnosticsProperty<bool>('initiallyExpanded', initiallyExpanded));
  }
}
