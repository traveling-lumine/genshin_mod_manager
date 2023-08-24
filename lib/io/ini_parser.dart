import 'dart:convert';
import 'dart:io';

IniFile readIniFile(File iniPath) {
  const encoding = AsciiCodec(allowInvalid: true);
  final result = IniFile();
  iniPath.readAsLinesSync(encoding: encoding).forEach((element) {

  });
  return result;
}

class IniFile {
  Map<String, IniSection> sectionMap = <String, IniSection>{};

  IniFile();
}

class IniSection {
  Set<Command> command = {};
}

class Command {
  String name;
  String content;

  Command(this.name, this.content);
}