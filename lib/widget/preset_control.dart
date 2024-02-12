import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/service/preset_service.dart';
import 'package:genshin_mod_manager/third_party/fluent_ui/red_filled_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PresetControlWidget extends StatelessWidget {
  final _controller = TextEditingController();
  final bool isLocal;
  final String? category;

  String get _localPreset => isLocal ? 'Local' : 'Global';

  PresetControlWidget({super.key, required this.isLocal, this.category}) {
    if (isLocal && category == null) {
      throw ArgumentError.notNull('category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddIcon(context),
        const SizedBox(width: 8),
        _buildComboBox(),
      ],
    );
  }

  Widget _buildComboBox() {
    return Selector<PresetService, List<String>>(
      selector: (p0, p1) =>
          isLocal ? p1.getLocalPresets(category!) : p1.getGlobalPresets(),
      builder: (context, value, child) => RepaintBoundary(
        child: ComboBox(
          items: value
              .map((e) => ComboBoxItem(value: e, child: Text(e)))
              .toList(growable: false),
          placeholder: Text('$_localPreset Preset...'),
          onChanged: (value) => showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context2) => _presetDialog(value!, context2, context),
          ),
        ),
      ),
    );
  }

  ContentDialog _presetDialog(
      String name, BuildContext dialogContext, BuildContext buildContext) {
    return ContentDialog(
      title: Text('Apply $_localPreset Preset?'),
      content: Text('Preset name: $name'),
      actions: [
        RedFilledButton(
          onPressed: () {
            dialogContext.pop();
            if (isLocal) {
              buildContext
                  .read<PresetService>()
                  .removeLocalPreset(category!, name);
            } else {
              buildContext.read<PresetService>().removeGlobalPreset(name);
            }
          },
          child: const Text('Delete'),
        ),
        Button(
          onPressed: dialogContext.pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            dialogContext.pop();
            if (isLocal) {
              buildContext
                  .read<PresetService>()
                  .setLocalPreset(category!, name);
            } else {
              buildContext.read<PresetService>().setGlobalPreset(name);
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildAddIcon(BuildContext context) {
    return RepaintBoundary(
      child: IconButton(
        icon: const Icon(FluentIcons.add),
        onPressed: () => showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context2) => _addDialog(context2, context),
        ),
      ),
    );
  }

  Widget _addDialog(BuildContext dialogContext, BuildContext buildContext) {
    return ContentDialog(
      title: Text('Add $_localPreset Preset'),
      content: SizedBox(
        height: 40,
        child: TextBox(
          controller: _controller,
          placeholder: 'Preset Name',
        ),
      ),
      actions: [
        Button(
          onPressed: () {
            dialogContext.pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            dialogContext.pop();
            final text = _controller.text;
            _controller.clear();
            if (isLocal) {
              buildContext
                  .read<PresetService>()
                  .addLocalPreset(category!, text);
            } else {
              buildContext.read<PresetService>().addGlobalPreset(text);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
