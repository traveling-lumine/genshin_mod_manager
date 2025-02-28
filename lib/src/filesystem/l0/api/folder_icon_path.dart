import 'disposable.dart';

abstract interface class FolderIconPath implements Disposable {
  Stream<String?> get path;
}
