import 'dart:io';

import 'package:collection/collection.dart';

import '../../fs_interface/domain/helper/fsops.dart';
import '../../fs_interface/domain/helper/path_op_string.dart';
import '../entity/mod.dart';
import '../entity/mod_category.dart';

List<Mod> collectModUseCase({
  required final ModCategory category,
  required final bool enabledModsFirst,
}) =>
    getUnderSync<Directory>(category.path)
        .map(
          (final e) => Mod(
            path: e,
            displayName: e.pEnabledForm.pBasename,
            isEnabled: e.pIsEnabled,
            category: category,
          ),
        )
        .toList()
      ..sort((final a, final b) {
        if (enabledModsFirst) {
          final aEnabled = a.isEnabled;
          final bEnabled = b.isEnabled;
          if (aEnabled && !bEnabled) {
            return -1;
          } else if (!aEnabled && bEnabled) {
            return 1;
          }
        }
        return compareNatural(a.displayName, b.displayName);
      });
