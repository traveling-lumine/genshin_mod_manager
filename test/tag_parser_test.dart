import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/ui/util/tag_parser.dart';

void main() {
  group('AND operation', () {
    test('Completeness', () {
      final tags = {'a', 'b', 'c'};
      final result = parseTagQuery('a & b & c')(tags);
      expect(result, true);
    });
    test('Soundness', () {
      final tags = {'a', 'b'};
      final result = parseTagQuery('a & b & c')(tags);
      expect(result, false);
    });
  });
  group('OR operation', () {
    test('Completeness', () {
      final tags = {'a', 'b', 'c'};
      final result = parseTagQuery('a | b | c')(tags);
      expect(result, true);
    });
    test('Soundness', () {
      final tags = {'d', 'e'};
      final result = parseTagQuery('a | b | c')(tags);
      expect(result, false);
    });
  });
  group('NOT operation', () {
    test('Completeness', () {
      final tags = {'a'};
      final result = parseTagQuery('!a')(tags);
      expect(result, false);
    });
    test('Soundness', () {
      final tags = {'b', 'c'};
      final result = parseTagQuery('!a')(tags);
      expect(result, true);
    });
  });
  group('Operator precedence', () {
    test('Entry 01', () {
      final tags = {'c'};
      final result = parseTagQuery('a & b | c')(tags);
      expect(result, true);
      final result2 = parseTagQuery('a | b & c')(tags);
      expect(result2, false);
    });
    test('Entry 02', () {
      final tags = {'a'};
      final result = parseTagQuery('(a | b) & c')(tags);
      expect(result, false);
      final result2 = parseTagQuery('a | (b & c)')(tags);
      expect(result2, true);
    });
  });
  group('Errors', () {
    test('Unexpected token', () {
      expect(() => parseTagQuery('a &'), throwsException);
    });
    test('Unmatched parenthesis', () {
      expect(() => parseTagQuery('(a & b'), throwsException);
    });
  });
}
