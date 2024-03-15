import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class ModCategory {
  const ModCategory({
    required this.path,
    required this.name,
    this.iconPath,
  });

  final String path;
  final String name;
  final String? iconPath;

  @override
  String toString() =>
      'ModCategory(path: $path, name: $name, iconPath: $iconPath)';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ModCategory &&
        other.path == path &&
        other.name == name &&
        other.iconPath == iconPath;
  }

  @override
  int get hashCode => path.hashCode ^ name.hashCode ^ iconPath.hashCode;
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
  Object? convert(final Object? input) {
    if (input == null) {
      return null;
    }
    if (input is! List) {
      throw FormatException('Cannot decode type ${input.runtimeType}');
    }
    if (input.length != 4) {
      throw FormatException('Cannot decode list of length ${input.length}');
    }
    if (input[0] != 'ModCategory') {
      throw FormatException('Cannot decode type ${input[0]}');
    }
    return ModCategory(
      path: input[1] as String,
      name: input[2] as String,
      iconPath: input[3] as String?,
    );
  }
}

class _MyExtraEncoder extends Converter<Object?, Object?> {
  const _MyExtraEncoder();

  @override
  Object? convert(final Object? input) {
    if (input == null) {
      return null;
    }
    if (input is! ModCategory) {
      throw FormatException('Cannot encode type ${input.runtimeType}');
    }
    return <Object?>[
      'ModCategory',
      input.path,
      input.name,
      input.iconPath,
    ];
  }
}
