import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/constants.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'folder_icon.g.dart';

final showFolderIconKey = StorageAccessKey.showFolderIcon.name;
const showFolderIconDefault = true;

@riverpod
class FolderIcon extends _$FolderIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return watch?.getBool(showFolderIconKey) ?? showFolderIconDefault;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    read?.setBool(showFolderIconKey, value);
    state = value;
  }
}
