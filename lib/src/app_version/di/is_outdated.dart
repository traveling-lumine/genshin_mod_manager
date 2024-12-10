import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'current_version.dart';
import 'remote_version.dart';

part 'is_outdated.g.dart';

@riverpod
Future<bool> isOutdated(final IsOutdatedRef ref) async {
  final localFuture = ref.watch(versionStringProvider.future);
  final remoteFuture = ref.watch(remoteVersionProvider.future);
  final [local, remote] = await Future.wait([localFuture, remoteFuture]);
  if (local == null || remote == null) {
    return false;
  }
  return remote > local;
}
