import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../l0/api/category_repo.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod_category.dart';
import '../helper.dart';

class CategoryRepoImpl implements CategoryRepo {
  factory CategoryRepoImpl({
    required final String modRoot,
    required final Watcher directoryWatcher,
  }) {
    final streamController = StreamController<List<ModCategory>>();
    StreamSubscription<List<ModCategory>>? subscription;

    unawaited(
      readCategories(modRoot).then<void>(
        (final value) {
          if (streamController.isClosed) {
            return;
          }
          streamController.add(value);
          subscription = directoryWatcher.stream
              .asyncMap(
                (final event) => readCategories(modRoot),
              )
              .distinct(const ListEquality<ModCategory>().equals)
              .listen(
                streamController.add,
                onError: streamController.addError,
                onDone: streamController.close,
              );
        },
      ).onError(streamController.addError),
    );

    return CategoryRepoImpl._(
      categories: streamController.stream,
      onDispose: () async {
        await subscription?.cancel();
        await streamController.close();
      },
    );
  }

  factory CategoryRepoImpl.empty() =>
      CategoryRepoImpl._(categories: Stream.value(<ModCategory>[]));

  const CategoryRepoImpl._({
    required this.categories,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<ModCategory>> categories;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }

  static Future<List<ModCategory>> readCategories(final String modRoot) async {
    final list = await pathsUnder<Directory>(modRoot);
    return list
        .map((final e) => ModCategory(path: e, name: p.basename(e)))
        .toList()
      ..sort((final a, final b) => compareNatural(a.name, b.name));
  }
}
