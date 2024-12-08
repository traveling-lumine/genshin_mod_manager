import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/di/games_list.dart';
import '../../storage/di/storage.dart';
import '../constants.dart';
import '../widget/appbar.dart';

/// A route that shows a loading screen.
class LoadingRoute extends HookConsumerWidget {
  /// Creates a [LoadingRoute].
  const LoadingRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(persistentStorageProvider, (final previous, final next) {
      if (next.hasValue) {
        _goToLanding(context, ref);
      }
    });
    return ref.watch(persistentStorageProvider).when(
          data: (final data) => _buildData(data, ref),
          error: (final error, final stackTrace) => _buildError(error, ref),
          loading: _buildLoading,
        );
  }

  Widget _buildData(final Object? data, final WidgetRef ref) {
    final context = useContext();
    return _TitledNavView(
      title: 'Done!',
      children: [
        const Text('Done!'),
        const SizedBox(height: 16),
        Button(
          onPressed: () => _goToLanding(context, ref),
          child: const Text('Go to Home'),
        ),
      ],
    );
  }

  Widget _buildError(final Object error, final WidgetRef ref) => _TitledNavView(
        title: 'Error!',
        children: [
          Text('Error: $error'),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                onPressed: () => ref.invalidate(persistentStorageProvider),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              Button(
                onPressed: () {
                  ref.read(persistentStorageProvider.notifier).useNullStorage();
                },
                child: const Text('Override'),
              ),
            ],
          ),
        ],
      );

  Widget _buildLoading() => const _TitledNavView(
        title: 'Loading...',
        children: [
          ProgressRing(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      );

  void _goToLanding(final BuildContext context, final WidgetRef ref) {
    final gamesEmpty = ref.read(gamesListProvider).isEmpty;
    context
        .goNamed(gamesEmpty ? RouteNames.firstpage.name : RouteNames.home.name);
  }
}

class _TitledNavView extends StatelessWidget {
  const _TitledNavView({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) => NavigationView(
        appBar: getAppbar(title),
        content: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}
