import 'dart:io';

import 'package:collection/collection.dart';

import '../../fs_interface/domain/helper/fsops.dart';
import '../../fs_interface/domain/helper/path_op_string.dart';
import '../entity/mod_category.dart';

List<ModCategory> collectCategoriesUseCase({required final String modRoot}) =>
    getUnderSync<Directory>(modRoot)
        .map((final e) => ModCategory(path: e, name: e.pBasename))
        .toList()
      ..sort((final a, final b) => compareNatural(a.name, b.name));
