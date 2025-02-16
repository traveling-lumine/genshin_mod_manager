import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/app_config_entry.dart';
import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import 'setting_element.dart';

class SwitchSetting extends StatelessWidget {
  const SwitchSetting({
    required this.text,
    required this.entry,
    super.key,
    this.content,
  });
  final String text;
  final AppConfigEntry<bool> entry;
  final Widget? content;

  @override
  Widget build(final BuildContext context) => SettingElement(
        text: text,
        content: content,
        trailing: Consumer(
          builder: (final context, final ref, final child) => RepaintBoundary(
            child: ToggleSwitch(
              checked: ref.watch(
                appConfigFacadeProvider
                    .select((final value) => value.obtainValue(entry)),
              ),
              onChanged: (final value) {
                final newState = changeAppConfigUseCase<bool>(
                  appConfigFacade: ref.read(appConfigFacadeProvider),
                  appConfigPersistentRepo:
                      ref.read(appConfigPersistentRepoProvider),
                  entry: entry,
                  value: value,
                );
                ref.read(appConfigCProvider.notifier).setData(newState);
              },
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(DiagnosticsProperty<AppConfigEntry<bool>>('entry', entry));
  }
}
