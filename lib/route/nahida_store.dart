import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/upstream/api.dart';
import 'package:genshin_mod_manager/widget/thick_scrollbar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NahidaStoreRoute extends StatelessWidget {
  final _api = NahidaliveAPI();
  final String category;

  NahidaStoreRoute({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: Text('Akasha → $category'),
        leading: () {
          if (context.canPop()) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(FluentIcons.back),
                onPressed: () => context.pop(),
              ),
            );
          }
        }(),
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
                  return _StoreElement(
                      element: data[index], api: _api, category: category);
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
  final _passwordController = TextEditingController();
  final NahidaliveElement element;
  final NahidaliveAPI api;
  final String category;

  _StoreElement({
    required this.element,
    required this.api,
    required this.category,
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
      content: Text('This will download the mod to $category.'),
      actions: [
        Button(
          onPressed: () {
            Navigator.pop(dialogContext);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
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
              Navigator.pop(dialogContext);
              _download(context, _passwordController.text);
            },
          ),
        ),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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
      final parse = Uri.parse(url.downloadUrl!);
      final data = await api.download(url);
      if (!context.mounted) return;
      final length = data.length;
      final filename = parse.pathSegments.last;
      if (await _downloadFile(context, filename, data)) return;
      if (!context.mounted) return;
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

  Future<bool> _downloadFile(
      BuildContext context, String filename, Uint8List data) async {
    final catPath = context.read<AppStateService>().modRoot.pJoin(category);
    final enabledFormDirNames =
        getDirsUnder(catPath).map((e) => e.path.pBasename.pEnabledForm).toSet();
    String destDirName = filename.pBNameWoExt.pEnabledForm;
    while (!destDirName.pIsEnabled) {
      destDirName = destDirName.pEnabledForm;
    }
    int counter = 0;
    String noCollisionDestDirName = destDirName;
    while (enabledFormDirNames.contains(noCollisionDestDirName)) {
      counter++;
      noCollisionDestDirName = '$destDirName ($counter)';
    }
    destDirName = noCollisionDestDirName.pDisabledForm;
    final destDirPath = catPath.pJoin(destDirName);
    await Directory(destDirPath).create(recursive: true);
    try {
      final archive = ZipDecoder().decodeBytes(data);
      await extractArchiveToDiskAsync(archive, destDirPath, asyncWrite: true);
    } on Exception {
      if (!context.mounted) return true;
      unawaited(displayInfoBar(
        context,
        builder: (context, close) {
          return InfoBar(
            title: const Text('Download failed'),
            content: Text(
                'Failed to extract archive: $filename decode error. Instead, the archive was saved as $filename.'),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        },
      ));
      try {
        await File(catPath.pJoin(filename)).writeAsBytes(data);
      } catch (e) {
        print(e);
      }
      return true;
    }
    return false;
  }
}
