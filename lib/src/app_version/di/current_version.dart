import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repo/package_verison.dart';
import '../domain/entity/version.dart';

part 'current_version.g.dart';

@riverpod
Future<Version> versionString(final Ref ref) => getPackageVersion();
