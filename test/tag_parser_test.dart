import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/ui/util/tag_parser/tag_parser.dart';

void main() {
  group("AND operation", () {
    test("Completeness", () {
      final tags = {"a": true, "b": true, "c": true};
      final result = parseTagQuery("a & b & c").evaluate(tags);
      expect(result, true);
    });
    test("Soundness", () {
      final tags = {"a": true, "b": false, "c": true};
      final result = parseTagQuery("a & b & c").evaluate(tags);
      expect(result, false);
    });
  });
  group("OR operation", () {
    test("Completeness", () {
      final tags = {"a": true, "b": true, "c": false};
      final result = parseTagQuery("a | b | c").evaluate(tags);
      expect(result, true);
    });
    test("Soundness", () {
      final tags = {"a": false, "b": false, "c": false};
      final result = parseTagQuery("a | b | c").evaluate(tags);
      expect(result, false);
    });
  });
  group("NOT operation", () {
    test("Completeness", () {
      final tags = {"a": true};
      final result = parseTagQuery("!a").evaluate(tags);
      expect(result, false);
    });
    test("Soundness", () {
      final tags = {"a": false};
      final result = parseTagQuery("!a").evaluate(tags);
      expect(result, true);
    });
  });
  group("Operator precedence", () {
    test("Entry 01", () {
      final tags = {"a": false, "b": false, "c": true};
      final result = parseTagQuery("a & b | c").evaluate(tags);
      expect(result, true);
      final result2 = parseTagQuery("a | b & c").evaluate(tags);
      expect(result2, false);
    });
    test("Entry 02", () {
      final tags = {"a": true, "b": true, "c": false};
      final result = parseTagQuery("(a | b) & c").evaluate(tags);
      expect(result, false);
      final result2 = parseTagQuery("a | (b & c)").evaluate(tags);
      expect(result2, true);
    });
  });
  group("Errors", () {
    test("Unexpected token", () {
      expect(() => parseTagQuery("a &"), throwsException);
    });
    test("Unmatched parenthesis", () {
      expect(() => parseTagQuery("(a & b"), throwsException);
    });
  });
}
