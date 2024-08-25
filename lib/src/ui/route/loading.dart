import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../di/storage.dart';
import '../route_names.dart';
import '../widget/appbar.dart';

/// A route that shows a loading screen.
class LoadingRoute extends HookConsumerWidget {
  /// Creates a [LoadingRoute].
  const LoadingRoute({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    ref.listen(
      sharedPreferenceProvider,
      (final previous, final next) {
        if (next is AsyncData) {
          _goToMain(context);
        }
      },
    );
    return ref.watch(sharedPreferenceProvider).when(
          data: _buildData,
          error: (final error, final stackTrace) =>
              _buildError(error, context, ref),
          loading: _buildLoading,
        );
  }

  Widget _buildData(final Object? data) {
    final context = useContext();
    return _TitledNavView(
      title: 'Done!',
      children: [
        const Text('Done!'),
        const SizedBox(height: 16),
        Button(
          onPressed: () => _goToMain(context),
          child: const Text('Go to Home'),
        ),
      ],
    );
  }

  Widget _buildError(
    final Object error,
    final BuildContext context,
    final WidgetRef ref,
  ) =>
      _TitledNavView(
        title: 'Error!',
        children: [
          Text('Error: $error'),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                onPressed: () => ref.invalidate(sharedPreferenceProvider),
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              Button(
                onPressed: () => _goToMain(context),
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

  void _goToMain(final BuildContext context) =>
      context.go(RouteNames.home.name);
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
