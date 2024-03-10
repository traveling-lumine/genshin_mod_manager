import 'dart:io';

abstract interface class ProxyFileSystemWatcher<T extends FileSystemEntity> {
  Stream<List<T>> get entity;
}
