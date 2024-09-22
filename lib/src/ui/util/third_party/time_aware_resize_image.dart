// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'package:flutter/widgets.dart';
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class ResizeImageKey {
  const ResizeImageKey._(
    this._providerCacheKey,
    this._policy,
    this._width,
    this._height,
    this._allowUpscaling,
    this._mTime,
  );
  final Object _providerCacheKey;
  final ResizeImagePolicy _policy;
  final int? _width;
  final int? _height;
  final bool _allowUpscaling;
  final int _mTime;
  @override
  bool operator ==(final Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ResizeImageKey &&
        other._providerCacheKey == _providerCacheKey &&
        other._policy == _policy &&
        other._width == _width &&
        other._height == _height &&
        other._allowUpscaling == _allowUpscaling &&
        other._mTime == _mTime;
  }

  @override
  int get hashCode => Object.hash(
        _providerCacheKey,
        _policy,
        _width,
        _height,
        _allowUpscaling,
        _mTime,
      );
}

enum ResizeImagePolicy {
  exact,
  fit,
}

/// A copy of native [ResizeImage] from Flutter.
/// This [ImageProvider] differs from the native one by adding a [mTime] field
/// which enables the image to be reload when the [mTime] changes.
class ResizeImage extends ImageProvider<ResizeImageKey> {
  const ResizeImage(
    this.imageProvider, {
    required this.mTime,
    this.width,
    this.height,
    this.policy = ResizeImagePolicy.exact,
    this.allowUpscaling = false,
  }) : assert(width != null || height != null);
  final ImageProvider imageProvider;
  final int? width;
  final int? height;
  final ResizeImagePolicy policy;
  final bool allowUpscaling;
  final int mTime;
  static ImageProvider<Object> resizeIfNeeded(
    final int? cacheWidth,
    final int? cacheHeight,
    final ImageProvider<Object> provider,
    final int mTime,
  ) {
    if (cacheWidth != null || cacheHeight != null) {
      return ResizeImage(
        provider,
        width: cacheWidth,
        height: cacheHeight,
        mTime: mTime,
      );
    }
    return provider;
  }

  @override
  @Deprecated(
    'Implement loadImage for image loading. '
    'This feature was deprecated after v3.7.0-1.4.pre.',
  )
  ImageStreamCompleter loadBuffer(
    final ResizeImageKey key,
    final DecoderBufferCallback decode,
  ) {
    Future<ui.Codec> decodeResize(
      final ui.ImmutableBuffer buffer, {
      final int? cacheWidth,
      final int? cacheHeight,
      final bool? allowUpscaling,
    }) {
      assert(
        cacheWidth == null && cacheHeight == null && allowUpscaling == null,
        'ResizeImage cannot be composed with another ImageProvider that applies '
        'cacheWidth, cacheHeight, or allowUpscaling.',
      );
      return decode(
        buffer,
        cacheWidth: width,
        cacheHeight: height,
        allowUpscaling: this.allowUpscaling,
      );
    }

    final completer =
        imageProvider.loadBuffer(key._providerCacheKey, decodeResize);
    if (!kReleaseMode) {
      completer.debugLabel =
          '${completer.debugLabel} - Resized(${key._width}×${key._height})';
    }
    _configureErrorListener(completer, key);
    return completer;
  }

  @override
  ImageStreamCompleter loadImage(
    final ResizeImageKey key,
    final ImageDecoderCallback decode,
  ) {
    Future<ui.Codec> decodeResize(
      final ui.ImmutableBuffer buffer, {
      final ui.TargetImageSizeCallback? getTargetSize,
    }) {
      assert(
        getTargetSize == null,
        'ResizeImage cannot be composed with another ImageProvider that applies '
        'getTargetSize.',
      );
      return decode(
        buffer,
        getTargetSize: (final intrinsicWidth, final intrinsicHeight) {
          switch (policy) {
            case ResizeImagePolicy.exact:
              var targetWidth = width;
              var targetHeight = height;
              if (!allowUpscaling) {
                if (targetWidth != null && targetWidth > intrinsicWidth) {
                  targetWidth = intrinsicWidth;
                }
                if (targetHeight != null && targetHeight > intrinsicHeight) {
                  targetHeight = intrinsicHeight;
                }
              }
              return ui.TargetImageSize(
                width: targetWidth,
                height: targetHeight,
              );
            case ResizeImagePolicy.fit:
              final aspectRatio = intrinsicWidth / intrinsicHeight;
              final maxWidth = width ?? intrinsicWidth;
              final maxHeight = height ?? intrinsicHeight;
              var targetWidth = intrinsicWidth;
              var targetHeight = intrinsicHeight;
              if (targetWidth > maxWidth) {
                targetWidth = maxWidth;
                targetHeight = targetWidth ~/ aspectRatio;
              }
              if (targetHeight > maxHeight) {
                targetHeight = maxHeight;
                targetWidth = (targetHeight * aspectRatio).floor();
              }
              if (allowUpscaling) {
                if (width == null) {
                  assert(height != null);
                  targetHeight = height!;
                  targetWidth = (targetHeight * aspectRatio).floor();
                } else if (height == null) {
                  targetWidth = width!;
                  targetHeight = targetWidth ~/ aspectRatio;
                } else {
                  final derivedMaxWidth = (maxHeight * aspectRatio).floor();
                  final derivedMaxHeight = maxWidth ~/ aspectRatio;
                  targetWidth = math.min(maxWidth, derivedMaxWidth);
                  targetHeight = math.min(maxHeight, derivedMaxHeight);
                }
              }
              return ui.TargetImageSize(
                width: targetWidth,
                height: targetHeight,
              );
          }
        },
      );
    }

    final completer =
        imageProvider.loadImage(key._providerCacheKey, decodeResize);
    if (!kReleaseMode) {
      completer.debugLabel =
          '${completer.debugLabel} - Resized(${key._width}×${key._height})';
    }
    _configureErrorListener(completer, key);
    return completer;
  }

  void _configureErrorListener(
    final ImageStreamCompleter completer,
    final ResizeImageKey key,
  ) {
    completer.addEphemeralErrorListener((final exception, final stackTrace) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
    });
  }

  @override
  Future<ResizeImageKey> obtainKey(final ImageConfiguration configuration) {
    Completer<ResizeImageKey>? completer;
    SynchronousFuture<ResizeImageKey>? result;
    imageProvider.obtainKey(configuration).then((final key) {
      if (completer == null) {
        result = SynchronousFuture<ResizeImageKey>(
          ResizeImageKey._(key, policy, width, height, allowUpscaling, mTime),
        );
      } else {
        completer.complete(
          ResizeImageKey._(key, policy, width, height, allowUpscaling, mTime),
        );
      }
    });
    if (result != null) {
      return result!;
    }
    completer = Completer<ResizeImageKey>();
    return completer.future;
  }
}
