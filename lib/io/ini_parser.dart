import 'dart:convert';
import 'dart:io';

final commentPattern = RegExp(r'^;.*$');
final sectionHeaderPattern = RegExp(r'^\[(\w+?)\]$');

class IniFile {
  static IniFile readFromFile(File filePath) {
    const encoding = AsciiCodec(allowInvalid: true);
    final readLines = filePath.readAsLinesSync(encoding: encoding);

    final result = IniFile();
    dynamic stash;
    for (var line in readLines) {
      line = line.trim();
      if (commentPattern.hasMatch(line)) continue;
      if (sectionHeaderPattern.hasMatch(line)) {
        final sectionName = sectionHeaderPattern.firstMatch(line)!.group(1)!;
        stash = IniSection(sectionName);
      }
      final section = stash as IniSection;
      section.command.add(line);
    }
    return result;
  }

  List<IniSection> sections = [];
}

class IniSection {
  List<String> command = [];
  String name;

  IniSection(this.name);
}
