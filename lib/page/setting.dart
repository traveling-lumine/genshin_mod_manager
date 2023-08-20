import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state.dart';

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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Expanded(
                child: Text('Select 3D Migoto folder'),
              ),
              Button(
                child: const Icon(FluentIcons.folder_open),
                onPressed: () {
                  final dir = DirectoryPicker().getDirectory();
                  if (dir == null) return;
                  SharedPreferences.getInstance().then((instance) {
                    instance.setString('targetDir', dir.path);
                  });
                  context.read<AppState>().targetDir = dir.path;
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Expanded(
                child: Text('Select launcher'),
              ),
              Button(
                child: const Icon(FluentIcons.folder_open),
                onPressed: () {
                  final dir = OpenFilePicker().getFile();
                  if (dir == null) return;
                  SharedPreferences.getInstance().then((instance) {
                    instance.setString('launcherDir', dir.path);
                  });
                  context.read<AppState>().launcherDir = dir.path;
                },
              )
            ],
          ),
        ),
      ],
    );
  }
}
