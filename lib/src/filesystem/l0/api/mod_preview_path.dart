import 'disposable.dart';

abstract interface class ModPreviewPath implements Disposable {
  Stream<String?> get previewPath;
}
