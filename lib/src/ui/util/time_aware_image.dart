// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Modified a bit.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class TimeAwareImageKey {
  const TimeAwareImageKey._(
    this._providerCacheKey,
    this._mTime,
  );
  final Object _providerCacheKey;
  final int _mTime;
  @override
  bool operator ==(final Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TimeAwareImageKey &&
        other._providerCacheKey == _providerCacheKey &&
        other._mTime == _mTime;
  }

  @override
  int get hashCode => Object.hash(
        _providerCacheKey,
        _mTime,
      );
}

class TimeAwareImage extends ImageProvider<TimeAwareImageKey> {
  const TimeAwareImage(
    this.imageProvider, {
    required this.mTime,
  });
  final ImageProvider imageProvider;
  final int mTime;

  @override
  ImageStreamCompleter loadBuffer(
    final TimeAwareImageKey key,
    final DecoderBufferCallback decode,
  ) =>
      imageProvider.loadBuffer(key._providerCacheKey, decode);

  @override
  ImageStreamCompleter loadImage(
    final TimeAwareImageKey key,
    final ImageDecoderCallback decode,
  ) =>
      imageProvider.loadImage(key._providerCacheKey, decode);

  @override
  Future<TimeAwareImageKey> obtainKey(final ImageConfiguration configuration) {
    Completer<TimeAwareImageKey>? completer;
    SynchronousFuture<TimeAwareImageKey>? result;
    imageProvider.obtainKey(configuration).then((final key) {
      if (completer == null) {
        result = SynchronousFuture<TimeAwareImageKey>(
          TimeAwareImageKey._(key, mTime),
        );
      } else {
        completer.complete(
          TimeAwareImageKey._(key, mTime),
        );
      }
    });
    if (result != null) {
      return result!;
    }
    completer = Completer<TimeAwareImageKey>();
    return completer.future;
  }
}
