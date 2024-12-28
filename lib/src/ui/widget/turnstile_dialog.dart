import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../nahida/data/secrets.dart';

class TurnstileDialog extends StatelessWidget {
  const TurnstileDialog({super.key});

  @override
  Widget build(final BuildContext context) => FutureBuilder(
        // no idea why discarded_futures thing keeps appearing
        // ignore: discarded_futures
        future: WebviewController.getWebViewVersion(),
        builder: (final bCtx, final snapshot) {
          final closeButton = Button(
            onPressed: Navigator.of(bCtx).pop,
            child: const Text('Close'),
          );
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentDialog(
              title: const Text('Checking WebView version...'),
              content: const Center(child: ProgressRing()),
              actions: [closeButton],
            );
          }
          if (snapshot.hasError) {
            return ContentDialog(
              title: const Text('WebView error'),
              content: Text('Error: ${snapshot.error}'),
              actions: [closeButton],
            );
          }
          if (snapshot.data == null) {
            return ContentDialog(
              title: const Text('WebView not found'),
              content: const Text('Please install WebView2 runtime'),
              actions: [
                closeButton,
                FilledButton(
                  onPressed: () {
                    unawaited(
                      launchUrlString(
                        'https://developer.microsoft.com/en-us/microsoft-edge/webview2/',
                      ),
                    );
                    Navigator.of(bCtx).pop();
                  },
                  child: const Text('Download WebView2'),
                ),
              ],
            );
          }
          return ContentDialog(
            title: const Text('Beep boop...?'),
            content: const Center(child: _TurnstileWebview()),
            actions: [closeButton],
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          );
        },
      );
}

class _TurnstileWebview extends StatefulWidget {
  const _TurnstileWebview();

  @override
  State<_TurnstileWebview> createState() => __TurnstileWebviewState();
}

class __TurnstileWebviewState extends State<_TurnstileWebview>
    with ProtocolListener {
  final _controller = WebviewController();

  @override
  void onProtocolUrlReceived(final String url) {
    final uri = Uri.parse(url);
    final token = uri.queryParameters['token'];
    Navigator.of(context).pop(token);
  }

  @override
  Widget build(final BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Text('Initializing WebView...');
    } else {
      return Webview(
        _controller,
        permissionRequested: (
          final url,
          final permissionKind,
          final isUserInitiated,
        ) async =>
            _onPermissionRequested(
          context,
          url,
          permissionKind,
          isUserInitiated,
        ),
      );
    }
  }

  Future<void> initPlatformState() async {
    await _controller.initialize();
    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
    await _controller.loadUrl(Env.val14);
    await _controller.executeScript("""
console.log = function(message) {
  if (message === 'token:') {
    return;
  }
  if (!message.startsWith('token:')) {
    return;
  }
  var token = message.substring(6);
  window.location.href = 'gmm-interop-uri://nahida.live/?token=' + token;
}
""");

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    unawaited(initPlatformState());
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
    final BuildContext context,
    final String url,
    final WebviewPermissionKind kind,
    final bool isUserInitiated,
  ) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: context,
      builder: (final dCtx) => ContentDialog(
        title: const Text('WebView permission requested'),
        content: Text("WebView has requested permission '$kind'"),
        actions: <Widget>[
          Button(
            onPressed: () =>
                Navigator.of(dCtx).pop(WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dCtx).pop(WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    protocolHandler.removeListener(this);
    super.dispose();
  }
}
