import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../filesystem/l0/entity/folder_move_result.dart';
import '../../filesystem/l0/entity/mod_category.dart';
import '../../filesystem/l0/usecase/folder_drop.dart';
import '../../filesystem/l1/di/filesystem.dart';
import '../util/display_infobar.dart';
import 'fade_in.dart';

class CategoryDropTarget extends HookConsumerWidget {
  const CategoryDropTarget({
    required this.child,
    required this.category,
    super.key,
  });

  final Widget child;

  final ModCategory category;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final state = useState(false);
    return DropTarget(
      onDragEntered: (final details) {
        state.value = true;
      },
      onDragExited: (final details) {
        state.value = false;
      },
      onDragDone: (final details) =>
          unawaited(_onDragDone(details, context, ref)),
      child: FadeInWidget(
        visible: state.value,
        fadeTarget: _buildDropHint(ref, state),
        child: child,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }

  Widget _buildDropHint(final WidgetRef ref, final ValueNotifier<bool> state) {
    final context = useContext();
    final moveMethod = ref.watch(
      appConfigFacadeProvider
          .select((final value) => value.obtainValue(moveOnDrag)),
    )
        ? 'move'
        : 'copy';

    final typography = FluentTheme.of(context).typography;
    return RichText(
      text: TextSpan(
        text: 'Drop to $moveMethod to',
        style: typography.body,
        children: [
          TextSpan(text: ' ${category.name}', style: typography.bodyStrong),
        ],
      ),
    );
  }

  Future<void> _onDragDone(
    final DropDoneDetails details,
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final moveInsteadOfCopy =
        ref.read(appConfigFacadeProvider).obtainValue(moveOnDrag);

    final result = await dragToImportUseCase(
      dropPaths: details.files.map((final e) => e.path),
      category: category,
      type: moveInsteadOfCopy,
      fs: ref.read(filesystemProvider),
    );

    final exists = result.whereType<ImportDestinationExists>();

    if (exists.isNotEmpty) {
      final dragImportType = moveInsteadOfCopy ? 'moved' : 'copied';
      if (context.mounted) {
        unawaited(
          displayInfoBarInContext(
            context,
            title: const Text('Folder already exists'),
            content: Text('Some folders already exist'
                ' and were not $dragImportType'),
            severity: InfoBarSeverity.warning,
          ),
        );
      }
    }
  }
}
