import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/entity/entries.dart';
import '../constants.dart';

class EmptyGameRedirector extends ConsumerWidget {
  const EmptyGameRedirector({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
        appConfigFacadeProvider.select(
          (final value) => value.obtainValue(games).gameConfig.keys.toList(),
        ), (final previous, final next) {
      if (next.isEmpty) {
        context.goNamed(RouteNames.firstpage.name);
      }
    });
    return child;
  }
}
