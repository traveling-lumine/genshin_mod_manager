import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_version/data/github.dart';
import '../../app_version/di/is_outdated.dart';
import '../../app_version/di/remote_version.dart';
import '../../app_version/domain/entity/version.dart';
import '../../filesystem/l1/impl/path_op_string.dart';
import '../util/display_infobar.dart';
import '../util/open_url.dart';

Future<Never> _runUpdateScript() async {
  final url = Uri.parse('$kRepoReleases/download/GenshinModManager.zip');
  final response = await http.get(url);
  final archive = ZipDecoder().decodeBytes(response.bodyBytes);
  await extractArchiveToDisk(archive, Directory.current.path);
  const updateScript = 'setlocal\n'
      'echo update script running\n'
      'set "sourceFolder=GenshinModManager"\n'
      'if not exist "genshin_mod_manager.exe" (\n'
      '    echo Maybe not in the mod manager folder? Exiting for safety.\n'
      '    pause\n'
      '    exit /b 1\n'
      ')\n'
      'if not exist %sourceFolder% (\n'
      '    echo Failed to download data! Go to the link and install manually.\n'
      '    pause\n'
      '    exit /b 2\n'
      ')\n'
      "echo So it's good to go. Let's update.\n"
      "for /f \"delims=\" %%i in ('dir /b /a-d ^| findstr /v /i \"update.cmd update.log error.log\"') do del \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b /ad ^| findstr /v /i \"Resources %sourceFolder%\"') do rd /s /q \"%%i\"\n"
      "for /f \"delims=\" %%i in ('dir /b \"%sourceFolder%\"') do move /y \"%sourceFolder%\\%%i\" .\n"
      'rd /s /q %sourceFolder%\n'
      'start /b genshin_mod_manager.exe\n'
      'endlocal\n';
  await File('update.cmd').writeAsString(updateScript);
  await Process.start(
    'start',
    [
      'cmd',
      '/c',
      'timeout /t 3 && call update.cmd > update.log & del update.cmd',
    ],
    runInShell: true,
  );
  return exit(0);
}

class UpdatePopup extends ConsumerWidget {
  const UpdatePopup({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(isOutdatedProvider, (final previous, final next) async {
      if (next is AsyncData && next.requireValue) {
        final remote = await ref.read(remoteVersionProvider.future);
        if (context.mounted) {
          unawaited(_showUpdateInfoBar(context, ref, remote));
        }
      }
    });

    return child;
  }

  List<String> _findUpdateUnableReason(final WidgetRef ref) {
    final appState =
        ref.read(appConfigFacadeProvider).obtainValue(games).currentGameConfig;
    final modRoot = appState.modRoot;
    final migotoRoot = appState.modExecFile;
    final launcherRoot = appState.launcherFile;
    final execRoot = File(Platform.resolvedExecutable).parent.path;

    final reason = <String>[];
    if (modRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('mods');
    }
    if (migotoRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('3d migoto');
    }
    if (launcherRoot?.pIsWithin(execRoot) ?? false) {
      reason.add('launcher');
    }
    return reason;
  }

  Future<bool?> _showUpdateConfirmDialog(
    final BuildContext context,
    final WidgetRef ref,
  ) =>
      showDialog<bool?>(
        context: context,
        builder: (final dialogContext) {
          final reason = _findUpdateUnableReason(ref);
          final Widget filledButton;
          if (reason.isNotEmpty) {
            filledButton = MouseRegion(
              cursor: SystemMouseCursors.forbidden,
              child: Tooltip(
                message: 'The auto-update will delete one or more of the'
                    " following: ${reason.join(', ')}!",
                child: const FilledButton(
                  onPressed: null,
                  child: Text('Start'),
                ),
              ),
            );
          } else {
            filledButton = FilledButton(
              child: const Text('Start'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            );
          }

          return ContentDialog(
            title: const Text('Start auto update?'),
            content: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(
                    text: 'This will download the latest version'
                        ' and replace the current one.'
                        ' This feature is experimental'
                        ' and may not work as expected.\n',
                  ),
                  TextSpan(
                    text: 'Please backup your mods'
                        ' and resources before proceeding.\n'
                        'DELETION OF UNRELATED FILES IS POSSIBLE.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: Navigator.of(dialogContext).pop,
                child: const Text('Cancel'),
              ),
              FluentTheme(
                data: FluentThemeData(accentColor: Colors.red),
                child: filledButton,
              ),
            ],
          );
        },
      );

  Future<void> _showUpdateInfoBar(
    final BuildContext context,
    final WidgetRef ref,
    final Version newVersion,
  ) =>
      displayInfoBarInContext(
        context,
        duration: const Duration(minutes: 1),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              const TextSpan(text: 'New version available: '),
              TextSpan(
                text: newVersion.formatted,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '. Click '),
              TextSpan(
                text: 'here',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => openUrl(kRepoReleases),
              ),
              const TextSpan(text: ' to open link.'),
            ],
          ),
        ),
        action: FilledButton(
          onPressed: () async {
            final result = await _showUpdateConfirmDialog(context, ref);
            if (result ?? false) {
              await _runUpdateScript();
            }
          },
          child: const Text('Auto update'),
        ),
      );
}
