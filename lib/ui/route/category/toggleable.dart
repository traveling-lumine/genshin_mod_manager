import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/mod_switcher.dart';
import 'package:genshin_mod_manager/ui/service/app_state_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ToggleableMod extends StatelessWidget {
  static const shaderFixes = 'ShaderFixes';
  static final Logger logger = Logger();

  final Widget child;
  final String dirPath;

  const ToggleableMod({
    super.key,
    required this.child,
    required this.dirPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: child,
    );
  }

  void onTap(BuildContext context) {
    final isEnabled = dirPath.pBasename.pIsEnabled;
    var shaderFixesPath =
        context.read<AppStateService>().modExecFile.pDirname.pJoin(shaderFixes);
    if (isEnabled) {
      disable(
        shaderFixesPath: shaderFixesPath,
        modPathW: dirPath,
        onModRenameClash: (p0) => showDirectoryExists(context, p0),
        onShaderDeleteFailed: (e) =>
            errorDialog(context, 'Failed to delete files in ShaderFixes: $e'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    } else {
      enable(
        shaderFixesPath: shaderFixesPath,
        modPath: dirPath,
        onModRenameClash: (p0) => showDirectoryExists(context, p0),
        onShaderExists: (e) =>
            errorDialog(context, '${e.path} already exists!'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    }
  }

  void buildErrorDialog(BuildContext context) {
    return errorDialog(
      context,
      'Failed to rename folder.'
      ' Check if the ShaderFixes folder is open in explorer,'
      ' and close it if it is.',
    );
  }

  void showDirectoryExists(BuildContext context, String renameTarget) {
    errorDialog(context, '${renameTarget.pBasename} directory already exists!');
  }

  void errorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: Text(text),
        actions: [
          FilledButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
