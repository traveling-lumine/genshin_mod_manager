import 'dart:io';

List<String> getAllChildrenFolder(String dir) {
  List<String> a = [];
  Directory(dir).listSync().forEach((element) {
    if (element is Directory) {
      a.add(element.path);
    }
  });
  return a;
}

List<String> getActiveiniFiles(String dir) {
  List<String> a = [];
  Directory(dir).listSync().forEach((element) {
    var path = element.path;
    final filename = path.split('\\').last;
    if (element is File &&
        path.endsWith('.ini') &&
        !filename.contains('DISABLED')) {
      a.add(path);
    }
  });
  return a;
}

void runProgram(String program) {
  Process.run(
    'start',
    ['/d', File(program).parent.path, '', program],
    runInShell: true,
  );
}

void openFolder(String dir) {
  Process.start(
    'explorer',
    [dir],
    runInShell: true,
  );
}
