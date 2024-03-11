import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control/preset_control_vm.dart';
import 'package:provider/provider.dart';

class PresetControlWidget extends StatelessWidget {
  final bool isLocal;
  final ModCategory? category;

  PresetControlWidget({
    super.key,
    required this.isLocal,
    this.category,
  }) {
    if (isLocal && category == null) {
      throw ArgumentError.notNull('category for local preset control');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        if (isLocal) {
          return createLocalPresetControlViewModel(
            presetService: context.read(),
            category: category!,
          );
        } else {
          return createGlobalPresetControlViewModel(
            presetService: context.read(),
          );
        }
      },
      child: _PresetControlWidget(prefix: isLocal ? 'Local' : 'Global'),
    );
  }
}

class _PresetControlWidget extends StatefulWidget {
  final String prefix;

  const _PresetControlWidget({required this.prefix});

  @override
  State<_PresetControlWidget> createState() => _PresetControlWidgetState();
}

class _PresetControlWidgetState extends State<_PresetControlWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return Selector(
      selector: (_, PresetControlViewModel vm) => vm.presets,
      builder: (context, value, child) => RepaintBoundary(
        child: ComboBox(
          items: value
              .map((e) => ComboBoxItem(value: e, child: Text(e)))
              .toList(growable: false),
          placeholder: Text('${widget.prefix} Preset...'),
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
    final vm = context.read<PresetControlViewModel>();
    return ContentDialog(
      title: Text('Apply ${widget.prefix} Preset?'),
      content: Text('Preset name: $name'),
      actions: [
        FluentTheme(
          data: FluentTheme.of(buildContext).copyWith(accentColor: Colors.red),
          child: FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              vm.removePreset(name);
            },
            child: const Text('Delete'),
          ),
        ),
        Button(
          onPressed: Navigator.of(dialogContext).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            vm.setPreset(name);
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
    final vm = context.read<PresetControlViewModel>();
    return ContentDialog(
      title: Text('Add ${widget.prefix} Preset'),
      content: SizedBox(
        height: 40,
        child: TextBox(
          controller: _controller,
          placeholder: 'Preset Name',
        ),
      ),
      actions: [
        Button(
          onPressed: Navigator.of(dialogContext).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            final text = _controller.text;
            _controller.clear();
            vm.addPreset(text);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
