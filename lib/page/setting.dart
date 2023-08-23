import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';
import '../new_impl/no_deref_file_opener.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Settings'),
      ),
      children: [
        SettingItem(
          title: 'Select 3D Migoto folder',
          icon: FluentIcons.folder_open,
          path:
              context.select<AppState, String>((value) => value.targetDir.path),
          onPressed: () {
            final dir = DirectoryPicker().getDirectory();
            if (dir == null) return;
            SharedPreferences.getInstance().then((instance) {
              instance.setString('targetDir', dir.path);
            });
            context.read<AppState>().targetDir = dir;
          },
        ),
        SettingItem(
          title: 'Select launcher',
          icon: FluentIcons.document_management,
          path: context
              .select<AppState, String>((value) => value.launcherFile.path),
          onPressed: () {
            final file = OpenNoDereferenceFilePicker().getFile();
            if (file == null) return;
            SharedPreferences.getInstance().then((instance) {
              instance.setString('launcherDir', file.path);
            });
            context.read<AppState>().launcherFile = file;
          },
        ),
      ],
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final String path;
  final IconData icon;
  final VoidCallback? onPressed;

  const SettingItem({
    super.key,
    required this.title,
    required this.icon,
    required this.path,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FluentTheme.of(context).typography.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  path,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ],
            ),
          ),
          Button(
            onPressed: onPressed,
            child: Icon(icon),
          )
        ],
      ),
    );
  }
}
