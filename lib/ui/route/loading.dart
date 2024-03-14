import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/widget/appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class LoadingRoute extends StatelessWidget {
  const LoadingRoute({super.key});

  static const String _destinationRoute = kHomeRoute;
  static final Logger logger = Logger();

  @override
  Widget build(final BuildContext context) => FutureBuilder(
        // ignore: discarded_futures
        future: context.select<AppStateService, Future<bool>>(
          (final value) => value.successfulLoad,
        ),
        builder: (final context, final snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            logger.e('App FutureBuilder snapshot error: ${snapshot.error}');
            return _buildError(context, snapshot.error);
          }
          SchedulerBinding.instance.addPostFrameCallback((final timeStamp) {
            context.go(_destinationRoute);
          });
          return _buildDone(context);
        },
      );

  Widget _buildError(final BuildContext context, final Object? error) =>
      NavigationView(
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
                    onPressed: () => context.read<AppStateService>().reload(),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  Button(
                    onPressed: () => context.go(_destinationRoute),
                    child: const Text('Override'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildLoading() => NavigationView(
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

  Widget _buildDone(final BuildContext context) => NavigationView(
        appBar: getAppbar("Done!"),
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Done!'),
              const SizedBox(height: 16),
              Button(
                onPressed: () => context.go(_destinationRoute),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
}

NavigationAppBar getAppbar(final String text) => NavigationAppBar(
      actions: const WindowButtons(),
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text),
        ),
      ),
    );
