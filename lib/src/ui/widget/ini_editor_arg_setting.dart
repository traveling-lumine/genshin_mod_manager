import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';
import 'setting_element.dart';

class IniEditorArgSetting extends ConsumerWidget {
  const IniEditorArgSetting({required this.title, super.key});
  final String title;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final initString = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(iniEditorArg)),
    );
    return SettingElement(
      text: title,
      subTitle:
          const Text('Leave blank to use default. Use %0 for the file path.'),
      trailing: SizedBox(
        width: 300,
        child: TextFormBox(
          onChanged: (final value) {
            final newState = changeAppConfigUseCase(
              appConfigFacade: ref.read(appConfigFacadeProvider),
              appConfigPersistentRepo:
                  ref.read(appConfigPersistentRepoProvider),
              entry: iniEditorArg,
              value: value,
            );
            ref.read(appConfigCProvider.notifier).setData(newState);
          },
          initialValue: initString,
          placeholder: 'Arguments...',
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}
