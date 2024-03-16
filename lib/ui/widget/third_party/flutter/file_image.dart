// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// Method signature for _loadAsync decode callbacks.
typedef _SimpleDecoderCallback = Future<ui.Codec> Function(
    ui.ImmutableBuffer buffer);

/// Decodes the given [File] object as an image, associating it with the given
/// scale.
///
/// The provider does not monitor the file for changes. If you expect the
/// underlying data to change, you should call the [evict] method.
///
/// See also:
///
///  * [Image.file] for a shorthand of an [Image] widget backed by [FileImage2].
@immutable
class FileImage2 extends ImageProvider<FileImage2> {
  /// Creates an object that decodes a [File] as an image.
  const FileImage2(this.file, {this.scale = 1.0});

  /// The file to decode into an image.
  final File file;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<FileImage2> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FileImage2>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      FileImage2 key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  @override
  @protected
  ImageStreamCompleter loadImage(FileImage2 key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    FileImage2 key, {
    required _SimpleDecoderCallback decode,
  }) async {
    assert(key == this);
    // TODO(jonahwilliams): making this sync caused test failures that seem to
    // indicate that we can fail to call evict unless at least one await has
    // occurred in the test.
    // https://github.com/flutter/flutter/issues/113044
    final int lengthInBytes = await Future(file.lengthSync);
    if (lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }
    return decode(
        await ui.ImmutableBuffer.fromUint8List(file.readAsBytesSync()));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FileImage2 &&
        other.file.path == file.path &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(file.path, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'FileImage')}("${file.path}", scale: ${scale.toStringAsFixed(1)})';
}
