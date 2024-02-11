import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/route_refresh_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingRoute extends StatelessWidget {
  static final Logger logger = Logger();

  const LoadingRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final initFuture =
        context.select<AppStateService, Future<SharedPreferences>>(
            (value) => value.initFuture);
    return FutureBuilder(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoading();
        }
        if (snapshot.hasError) {
          logger.e('App FutureBuilder snapshot error: ${snapshot.error}');
          return _buildError(context, snapshot.error);
        }
        return _buildDone();
      },
    );
  }

  Widget _buildError(BuildContext context, Object? error) {
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
                  onPressed: () => context.read<AppStateService>().init(),
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                Button(
                  onPressed: () =>
                      context.read<RouteRefreshService>().refresh('/setting'),
                  child: const Text('Override'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return NavigationView(
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

  Widget _buildDone() {
    return NavigationView(
      appBar: getAppbar("Done!"),
      content: const Center(
        child: Text('Done!'),
      ),
    );
  }
}
