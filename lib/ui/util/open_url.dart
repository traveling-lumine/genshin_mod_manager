import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

/// Opens the given URL in the system's default browser.
void openUrl(final String url) {
  unawaited(launchUrl(Uri.parse(url)));
}
