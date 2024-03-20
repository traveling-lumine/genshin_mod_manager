import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/provider/app_state.dart';
import 'package:genshin_mod_manager/ui/widget/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

/// A route that shows a loading screen.
class LoadingRoute extends ConsumerWidget {
  /// Creates a [LoadingRoute].
  const LoadingRoute({super.key});

  static const String _destinationRoute = kHomeRoute;
  static final Logger _logger = Logger();

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final sharedPreference = ref.watch(sharedPreferenceProvider);
    return sharedPreference.when(
      data: (final data) => _buildData(context),
      error: (final error, final stackTrace) =>
          _buildError(error, ref, context),
      loading: _buildLoading,
    );
  }

  NavigationView _buildData(final BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((final timeStamp) {
      context.go(_destinationRoute);
    });
    return NavigationView(
      appBar: getAppbar("Done!"),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Done!'),
            const SizedBox(height: 16),
            Button(
              onPressed: () => context.go(LoadingRoute._destinationRoute),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }

  NavigationView _buildError(
    final Object error,
    final WidgetRef ref,
    final BuildContext context,
  ) {
    _logger.e('App FutureBuilder snapshot error: $error');
    return NavigationView(
      appBar: getAppbar("Error!"),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  onPressed: () => context.go(LoadingRoute._destinationRoute),
                  child: const Text('Override'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  NavigationView _buildLoading() => NavigationView(
        appBar: getAppbar("Loading..."),
        content: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(),
              Text('Loading...'),
            ],
          ),
        ),
      );
}
