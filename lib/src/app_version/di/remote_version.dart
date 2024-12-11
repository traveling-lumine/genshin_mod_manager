import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repo/remote_version.dart';
import '../domain/entity/version.dart';

part 'remote_version.g.dart';

@riverpod
Future<Version> remoteVersion(final Ref ref) => getRemoteVersion();
