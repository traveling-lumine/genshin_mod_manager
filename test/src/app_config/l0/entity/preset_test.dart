import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/app_config/l0/entity/preset.dart';

void main() {
  group('PresetList', () {
    test('FromJson', () {
      final presetList = PresetList.fromJson(['a', 'b', 'c']);
      expect(presetList.mods, ['a', 'b', 'c']);
    });
    test('ToJson', () {
      const presetList = PresetList(mods: ['a', 'b', 'c']);
      expect(presetList.toJson(), ['a', 'b', 'c']);
    });
  });
  group('PresetListMap', () {
    test('fromJson', () {
      final presetListMap = PresetListMap.fromJson({
        'aa': ['a', 'b', 'c'],
        'bb': ['d', 'e', 'f'],
      });
      expect(presetListMap.bundledPresets, {
        'aa': const PresetList(mods: ['a', 'b', 'c']),
        'bb': const PresetList(mods: ['d', 'e', 'f']),
      });
    });
    test('toJson', () {
      const presetListMap = PresetListMap(
        bundledPresets: {
          'aa': PresetList(mods: ['a', 'b', 'c']),
          'bb': PresetList(mods: ['d', 'e', 'f']),
        },
      );
      expect(presetListMap.toJson(), {
        'aa': ['a', 'b', 'c'],
        'bb': ['d', 'e', 'f'],
      });
    });
  });
  group('PresetData', () {
    test('FromJson', () {
      final presetData = PresetData.fromJson({
        'global': {
          'aa': {
            'aa': ['a', 'b', 'c'],
            'bb': ['d', 'e', 'f'],
          },
        },
        'local': {
          'cc': {
            'cc': ['g', 'h', 'i'],
            'dd': ['j', 'k', 'l'],
          },
        },
      });
      expect(presetData.global, {
        'aa': const PresetListMap(
          bundledPresets: {
            'aa': PresetList(mods: ['a', 'b', 'c']),
            'bb': PresetList(mods: ['d', 'e', 'f']),
          },
        ),
      });
      expect(presetData.local, {
        'cc': const PresetListMap(
          bundledPresets: {
            'cc': PresetList(mods: ['g', 'h', 'i']),
            'dd': PresetList(mods: ['j', 'k', 'l']),
          },
        ),
      });
    });
    test('toJson', () {
      const presetData = PresetData(
        global: {
          'aa': PresetListMap(
            bundledPresets: {
              'aa': PresetList(mods: ['a', 'b', 'c']),
              'bb': PresetList(mods: ['d', 'e', 'f']),
            },
          ),
        },
        local: {
          'cc': PresetListMap(
            bundledPresets: {
              'cc': PresetList(mods: ['g', 'h', 'i']),
              'dd': PresetList(mods: ['j', 'k', 'l']),
            },
          ),
        },
      );
      expect(presetData.toJson(), {
        'global': {
          'aa': {
            'aa': ['a', 'b', 'c'],
            'bb': ['d', 'e', 'f'],
          },
        },
        'local': {
          'cc': {
            'cc': ['g', 'h', 'i'],
            'dd': ['j', 'k', 'l'],
          },
        },
      });
    });
  });
  group('json convert', () {
    test('encode', () {
      const presetData = PresetData(
        global: {
          'aa': PresetListMap(
            bundledPresets: {
              'aa': PresetList(mods: ['a', 'b', 'c']),
              'bb': PresetList(mods: ['d', 'e', 'f']),
            },
          ),
        },
        local: {
          'cc': PresetListMap(
            bundledPresets: {
              'cc': PresetList(mods: ['g', 'h', 'i']),
              'dd': PresetList(mods: ['j', 'k', 'l']),
            },
          ),
        },
      );
      final encode = jsonEncode(presetData);
      expect(
        encode,
        '{"global":{"aa":{"aa":["a","b","c"],"bb":["d","e","f"]}},'
        '"local":{"cc":{"cc":["g","h","i"],"dd":["j","k","l"]}}}',
      );
    });
    test('decode', () {
      final decode = jsonDecode(
        '{"global":{"aa":{"aa":["a","b","c"],"bb":["d","e","f"]}},'
        '"local":{"cc":{"cc":["g","h","i"],"dd":["j","k","l"]}}}',
      );
      final presetData = PresetData.fromJson(decode as Map<String, dynamic>);
      expect(
        presetData,
        const PresetData(
          global: {
            'aa': PresetListMap(
              bundledPresets: {
                'aa': PresetList(mods: ['a', 'b', 'c']),
                'bb': PresetList(mods: ['d', 'e', 'f']),
              },
            ),
          },
          local: {
            'cc': PresetListMap(
              bundledPresets: {
                'cc': PresetList(mods: ['g', 'h', 'i']),
                'dd': PresetList(mods: ['j', 'k', 'l']),
              },
            ),
          },
        ),
      );
    });
  });
}
