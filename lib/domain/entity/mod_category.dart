import 'dart:convert';

class ModCategory {
  final String path;
  final String name;
  final String? iconPath;

  ModCategory({
    required this.path,
    required this.name,
    this.iconPath,
  });

  @override
  String toString() {
    return 'ModCategory(path: $path, name: $name, iconPath: $iconPath)';
  }
}

class ModCategoryCodec extends Codec<Object?, Object?> {
  const ModCategoryCodec();

  @override
  Converter<Object?, Object?> get decoder => const _MyExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _MyExtraEncoder();
}

class _MyExtraDecoder extends Converter<Object?, Object?> {
  const _MyExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is! List) {
      throw FormatException('Cannot decode type ${input.runtimeType}');
    }
    if (input.length != 4) {
      throw FormatException('Cannot decode list of length ${input.length}');
    }
    if (input[0] != 'ModCategory') {
      throw FormatException('Cannot decode type ${input[0]}');
    }
    try {
      return ModCategory(
        path: input[1] as String,
        name: input[2] as String,
        iconPath: input[3] as String?,
      );
    } catch (e) {
      throw FormatException('D\'oh! $e');
    }
  }
}

class _MyExtraEncoder extends Converter<Object?, Object?> {
  const _MyExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is! ModCategory) {
      throw FormatException('Cannot encode type ${input.runtimeType}');
    }
    try {
      return <Object?>[
        'ModCategory',
        input.path,
        input.name,
        input.iconPath,
      ];
    } catch (e) {
      throw FormatException('D\'oh! $e');
    }
  }
}
