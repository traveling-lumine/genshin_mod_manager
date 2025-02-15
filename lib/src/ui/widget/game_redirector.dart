import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../constants.dart';

class GameRedirector extends ConsumerWidget {
  const GameRedirector({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
        appConfigFacadeProvider.select(
          (final value) => value.obtainValue(games).gameConfig.keys.toList(),
        ), (final previous, final next) {
      if (next.isNotEmpty) {
        context.goNamed(RouteNames.home.name);
      }
    });
    return child;
  }
}
