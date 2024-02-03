import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/mod_switcher.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ToggleableMod extends StatelessWidget {
  static const shaderFixes = PathW('ShaderFixes');
  static final Logger logger = Logger();

  final Widget child;
  final PathW dirPath;

  const ToggleableMod({
    super.key,
    required this.child,
    required this.dirPath,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = dirPath.basename.isEnabled;
    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          disable(
            shaderFixesDir: context
                .read<AppStateService>()
                .modExecFile
                .dirname
                .join(shaderFixes)
                .toDirectory,
            modPathW: dirPath,
            onModRenameClash: (p0) => showDirectoryExists(context, p0),
            onShaderDeleteFailed: (e) => errorDialog(
                context, 'Failed to delete files in ShaderFixes: $e'),
            onModRenameFailed: () => buildErrorDialog(context),
          );
        } else {
          enable(
            shaderFixesDir: context
                .read<AppStateService>()
                .modExecFile
                .dirname
                .join(shaderFixes)
                .toDirectory,
            modPathW: dirPath,
            onModRenameClash: (p0) => showDirectoryExists(context, p0),
            onShaderExists: (e) =>
                errorDialog(context, '${e.path} already exists!'),
            onModRenameFailed: () => buildErrorDialog(context),
          );
        }
      },
      child: child,
    );
  }

  void buildErrorDialog(BuildContext context) {
    return errorDialog(
      context,
      'Failed to rename folder.'
      ' Check if the ShaderFixes folder is open in explorer,'
      ' and close it if it is.',
    );
  }

  void showDirectoryExists(BuildContext context, PathW renameTarget) {
    errorDialog(context, '${renameTarget.basename} directory already exists!');
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
