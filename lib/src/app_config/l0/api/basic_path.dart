import 'dart:io';

abstract interface class BasicPathProvider {
  Directory get workDir;
  Directory get resourceDir;
  File get settingFile;
  Directory getIconRoot(final String gameName);
}
