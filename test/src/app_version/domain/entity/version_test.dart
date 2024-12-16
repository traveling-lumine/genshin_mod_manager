import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_version/domain/entity/version.dart';

void main() {
  group('Version.parse', () {
    test('parses version string', () {
      final version = Version.parse('1.2.3');
      expect(version.major, 1);
      expect(version.minor, 2);
      expect(version.patch, 3);
      expect(version.build, null);
    });

    test('parses version string with build', () {
      final version = Version.parse('1.2.3+4');
      expect(version.major, 1);
      expect(version.minor, 2);
      expect(version.patch, 3);
      expect(version.build, 4);
    });

    test('throws Error if invalid version format', () {
      expect(() => Version.parse('1.2'), throwsArgumentError);
      expect(() => Version.parse('a.b.c'), throwsFormatException);
      expect(() => Version.parse(''), throwsArgumentError);
      expect(() => Version.parse('1.2.3+'), throwsFormatException);
      expect(() => Version.parse('1.2.3+4+5'), throwsArgumentError);
    });
  });
  group('Version.formatted', () {
    test('formats version string', () {
      final version = Version(major: 1, minor: 2, patch: 3);
      expect(version.formatted, '1.2.3');
    });

    test('formats version string with build', () {
      final version = Version(major: 1, minor: 2, patch: 3, build: 4);
      expect(version.formatted, '1.2.3+4');
    });
  });
  group('Version comparison', () {
    group('Major', () {
      test('major is greater', () {
        final v1 = Version(major: 2, minor: 0, patch: 0);
        final v2 = Version(major: 1, minor: 0, patch: 0);
        expect(v1 > v2, isTrue);
      });
      test('major is not greater: less', () {
        final v1 = Version(major: 1, minor: 0, patch: 0);
        final v2 = Version(major: 2, minor: 0, patch: 0);
        expect(v1 > v2, isFalse);
      });
      test('major is not greater: equal', () {
        final v1 = Version(major: 1, minor: 0, patch: 0);
        final v2 = Version(major: 1, minor: 0, patch: 0);
        expect(v1 > v2, isFalse);
      });
    });
    group('Minor', () {
      test('minor is greater', () {
        final v1 = Version(major: 1, minor: 2, patch: 0);
        final v2 = Version(major: 1, minor: 1, patch: 0);
        expect(v1 > v2, isTrue);
      });
      test('minor is not greater: less', () {
        final v1 = Version(major: 1, minor: 1, patch: 0);
        final v2 = Version(major: 1, minor: 2, patch: 0);
        expect(v1 > v2, isFalse);
      });
      test('minor is not greater: equal', () {
        final v1 = Version(major: 1, minor: 1, patch: 0);
        final v2 = Version(major: 1, minor: 1, patch: 0);
        expect(v1 > v2, isFalse);
      });
    });
    group('Patch', () {
      test('patch is greater', () {
        final v1 = Version(major: 1, minor: 1, patch: 2);
        final v2 = Version(major: 1, minor: 1, patch: 1);
        expect(v1 > v2, isTrue);
      });
      test('patch is not greater: less', () {
        final v1 = Version(major: 1, minor: 1, patch: 1);
        final v2 = Version(major: 1, minor: 1, patch: 2);
        expect(v1 > v2, isFalse);
      });
      test('patch is not greater: equal', () {
        final v1 = Version(major: 1, minor: 1, patch: 1);
        final v2 = Version(major: 1, minor: 1, patch: 1);
        expect(v1 > v2, isFalse);
      });
    });
    group('Build', () {
      test('build is greater', () {
        final v1 = Version(major: 1, minor: 1, patch: 1, build: 2);
        final v2 = Version(major: 1, minor: 1, patch: 1, build: 1);
        expect(v1 > v2, isTrue);
      });
      test('build is not greater: less', () {
        final v1 = Version(major: 1, minor: 1, patch: 1, build: 1);
        final v2 = Version(major: 1, minor: 1, patch: 1, build: 2);
        expect(v1 > v2, isFalse);
      });
      test('build is not greater: equal', () {
        final v1 = Version(major: 1, minor: 1, patch: 1, build: 1);
        final v2 = Version(major: 1, minor: 1, patch: 1, build: 1);
        expect(v1 > v2, isFalse);
      });
    });
    group('Build with one or more null', () {
      test('build is greater', () {
        final v1 = Version(major: 1, minor: 1, patch: 1, build: 2);
        final v2 = Version(major: 1, minor: 1, patch: 1);
        expect(v1 > v2, isTrue);
      });
      test('build is not greater: less', () {
        final v1 = Version(major: 1, minor: 1, patch: 1);
        final v2 = Version(major: 1, minor: 1, patch: 1, build: 2);
        expect(v1 > v2, isFalse);
      });
      test('build is not greater: equal', () {
        final v1 = Version(major: 1, minor: 1, patch: 1);
        final v2 = Version(major: 1, minor: 1, patch: 1);
        expect(v1 > v2, isFalse);
      });
    });
  });
}
