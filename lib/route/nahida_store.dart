import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/upstream/api.dart';
import 'package:genshin_mod_manager/widget/thick_scrollbar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class NahidaStoreRoute extends StatelessWidget {
  final _api = NahidaliveAPI();

  NahidaStoreRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: const PageHeader(
        title: Text('Akasha'),
      ),
      content: FutureBuilder(
        future: _api.fetchNahidaliveElements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: ProgressRing());
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ThickScrollbar(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
                  minCrossAxisExtent: 500,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return _StoreElement(element: data[index], api: _api);
                },
              ),
            );
          }
          return Text(
              'Unable to fetch data. Report this to the developer: $snapshot');
        },
      ),
    );
  }
}

class _StoreElement extends StatelessWidget {
  final NahidaliveElement element;
  final NahidaliveAPI api;
  final _passwordController = TextEditingController();

  _StoreElement({
    required this.element,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      element.previewUrl,
      fit: BoxFit.contain,
    );
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        element.title,
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                    ),
                    RepaintBoundary(
                      child: Button(
                        onPressed: () => showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (dialogContext) =>
                              _downloadDialog(dialogContext, context),
                        ),
                        child: const Icon(FluentIcons.download),
                      ),
                    ),
                  ],
                ),
                Text(element.description),
                if (element.tags.isNotEmpty)
                  Text('Tags: ${element.tags.join(', ')}'),
                if (element.arcaUrl != null)
                  Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: element.arcaUrl,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap =
                                  () => launchUrl(Uri.parse(element.arcaUrl!)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    onSecondaryTap: () => Navigator.of(context).pop(),
                    child: image,
                  ),
                ),
                child: image,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadDialog(BuildContext dialogContext, BuildContext context) {
    return ContentDialog(
      title: Text('Download ${element.title}?'),
      content: const Text('This will download the mod to memory.'),
      actions: [
        Button(
          onPressed: () {
            dialogContext.pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            dialogContext.pop();
            _download(context);
          },
          child: const Text('Download'),
        ),
      ],
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ContentDialog(
        title: const Text('Enter password'),
        content: SizedBox(
          height: 40,
          child: TextBox(
            focusNode: FocusNode()..requestFocus(),
            controller: _passwordController,
            placeholder: 'Password',
            onSubmitted: (value) async {
              dialogContext.pop();
              _download(context, _passwordController.text);
            },
          ),
        ),
        actions: [
          Button(
            onPressed: () {
              dialogContext.pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              dialogContext.pop();
              _download(context, _passwordController.text);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _download(BuildContext context, [String? pw]) async {
    final NahidaliveDownloadElement url;
    try {
      url = await api.downloadUrl(element.uuid, pw);
    } on HttpException catch (e) {
      if (!context.mounted) return;
      unawaited(displayInfoBar(
        context,
        builder: (infoBarContext, close) => InfoBar(
          title: const Text('Download failed'),
          content: Text('${e.uri}'),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      ));
      return;
    }
    if (url.status) {
      var parse = Uri.parse(url.downloadUrl!);
      final data = await api.download(url);
      if (!context.mounted) return;
      var length = data.length;
      var filename = parse.pathSegments.last;
      print('Downloaded ${element.title} with length $length');
      unawaited(displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: Text('Downloaded ${element.title}'),
            content: Text('Length: $length bytes'),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        },
      ));
    } else if (url.errorCodes == "403") {
      if (!context.mounted) return;
      _showPasswordDialog(context);
    } else {
      if (!context.mounted) return;
      unawaited(displayInfoBar(
        context,
        builder: (infoBarContext, close) => InfoBar(
          title: const Text('Download failed'),
          content: Text(url.toString()),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      ));
    }
  }
}
