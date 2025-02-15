import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../filesystem/di/mod_card.dart';
import '../../filesystem/l0/entity/ini.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l0/usecase/open_folder.dart';
import '../util/display_infobar.dart';
import '../util/show_prompt_dialog.dart';
import 'ini_widget.dart';
import 'mod_draggable.dart';
import 'mod_image_display.dart';
import 'mod_toggler.dart';

class ModCard extends StatelessWidget {
  const ModCard({required this.mod, super.key});
  final Mod mod;
  static const _minIniSectionWidth = 165.0;

  @override
  Widget build(final BuildContext context) => ModDraggable(
        mod: mod,
        child: ModToggler(
          mod: mod,
          child: Consumer(
            builder: (final context, final ref, final child) {
              final isBright =
                  FluentTheme.of(context).brightness == Brightness.light;
              final isEnabled2 = mod.isEnabled;
              final entry = switch ((isBright, isEnabled2)) {
                (false, false) => cardColorDarkDisabled,
                (false, true) => cardColorDarkEnabled,
                (true, false) => cardColorBrightDisabled,
                (true, true) => cardColorBrightEnabled,
              };
              final watch = ref.watch(
                appConfigFacadeProvider
                    .select((final value) => value.obtainValue(entry)),
              );
              return Card(
                backgroundColor: watch,
                padding: const EdgeInsets.all(6),
                child: child!,
              );
            },
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  _buildFolderHeader(context),
                  const SizedBox(height: 4),
                  Expanded(child: _buildFolderContent()),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', mod));
  }

  Widget _buildFolderContent() => Consumer(
        builder: (final _, final ref, final child) {
          final iniPaths = ref.watch(iniPathsProvider(mod));
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: iniPaths.when(
              data: (final data) {
                final isEmpty = data.isEmpty;
                return Row(
                  mainAxisAlignment: isEmpty
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: child!),
                    if (!isEmpty) _buildIni(data),
                  ],
                );
              },
              error: (final error, final stackTrace) =>
                  const Text('Error loading ini files'),
              loading: () => child!,
            ),
          );
        },
        child: Center(child: ModImageDisplay(mod: mod)),
      );

  Widget _buildFolderHeader(final BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              mod.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
          ),
          _buildIconButton(
            icon: FluentIcons.command_prompt,
            onPressed: _onCommand,
          ),
          _buildIconButton(
            icon: FluentIcons.delete,
            onPressed: () async => _onDeletePressed(context),
          ),
          _buildIconButton(
            icon: FluentIcons.folder_open,
            onPressed: _onFolderOpen,
          ),
        ],
      );

  Widget _buildIconButton({
    required final IconData icon,
    required final VoidCallback onPressed,
  }) =>
      RepaintBoundary(
        child: IconButton(icon: Icon(icon), onPressed: onPressed),
      );

  Widget _buildIni(final List<String> iniPaths) => Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(direction: Axis.vertical),
          ),
          Card(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            padding: const EdgeInsets.all(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _minIniSectionWidth),
              child: ListView.builder(
                itemBuilder: (final context, final index) => IniWidget(
                  iniFile: IniFile(path: iniPaths[index], mod: mod),
                ),
                itemCount: iniPaths.length,
              ),
            ),
          ),
        ],
      );

  Future<void> _onCommand() async {
    await Process.run(
      'start',
      ['powershell'],
      workingDirectory: mod.path,
      runInShell: true,
    );
  }

  Future<void> _onDeletePressed(final BuildContext context) async {
    final userResponse = await showPromptDialog(
      context: context,
      title: 'Delete mod?',
      content: const Text('Are you sure you want to delete this mod?'),
      confirmButtonLabel: 'Delete',
      redButton: true,
    );
    if (!userResponse) {
      return;
    }
    Directory(mod.path).deleteSync(recursive: true);
    if (context.mounted) {
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Mod deleted'),
          content: Text('Mod deleted from ${mod.path}'),
          severity: InfoBarSeverity.warning,
        ),
      );
    }
  }

  Future<void> _onFolderOpen() async {
    await openFolderUseCase(mod.path);
  }
}
