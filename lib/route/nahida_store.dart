import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/upstream/api.dart';
import 'package:genshin_mod_manager/widget/thick_scrollbar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NahidaStoreRoute extends StatefulWidget {
  final String category;

  const NahidaStoreRoute({super.key, required this.category});

  @override
  State<NahidaStoreRoute> createState() => _NahidaStoreRouteState();
}

class _NahidaStoreRouteState extends State<NahidaStoreRoute> {
  final _api = NahidaliveAPI();
  ScrollController _scrollController = ScrollController();
  late Future<List<NahidaliveElement>> future = _api.fetchNahidaliveElements();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(
        title: Text('${widget.category} ← Akasha'),
        leading: () {
          if (context.canPop()) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: RepaintBoundary(
                child: IconButton(
                  icon: const Icon(FluentIcons.back),
                  onPressed: () => context.pop(),
                ),
              ),
            );
          }
        }(),
        commandBar: RepaintBoundary(
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.refresh),
                onPressed: () {
                  setState(() {
                    future = _api.fetchNahidaliveElements();
                    final prevController = _scrollController;
                    _scrollController = ScrollController(
                      initialScrollOffset: prevController.offset,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
      content: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: ProgressRing());
          }
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ThickScrollbar(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
                  minCrossAxisExtent: 500,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return RevertScrollbar(
                    child: _StoreElement(
                      element: data[index],
                      api: _api,
                      category: widget.category,
                    ),
                  );
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
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (context) => GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              onSecondaryTap: () => Navigator.of(context).pop(),
              child: child,
            ),
          ),
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        final expectedTotalBytes = loadingProgress.expectedTotalBytes;
        final value = expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / expectedTotalBytes
            : null;
        return Center(
          child: ProgressRing(
            value: value,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.error),
            Text('Failed to load image: ${error.runtimeType}\n$error'),
          ],
        );
      },
    );
    final primaryItems = <CommandBarItem>[];
    final virustotalUrl = element.virustotalUrl;
    final arcaUrl = element.arcaUrl;
    if (virustotalUrl != null && virustotalUrl.isNotEmpty) {
      primaryItems.add(CommandBarButton(
        onPressed: () => launchUrl(Uri.parse(virustotalUrl)),
        icon: const Icon(FluentIcons.shield_alert),
      ));
    }
    if (arcaUrl != null && arcaUrl.isNotEmpty) {
      primaryItems.add(CommandBarButton(
        onPressed: () => launchUrl(Uri.parse(arcaUrl)),
        icon: const ImageIcon(
          AssetImage('images/arca_logo.png'),
        ),
      ));
    }
    primaryItems.add(CommandBarButton(
      onPressed: () => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => _downloadDialog(dialogContext, context),
      ),
      icon: const Icon(FluentIcons.download),
    ));
    final double commandWidth;
    switch (primaryItems.length) {
      case 1:
        commandWidth = 42;
        break;
      case 2:
        commandWidth = 70;
        break;
      case 3:
        commandWidth = 98;
        break;
      default:
        throw ArgumentError('Too many primary items');
    }
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: _buildDescriptionColumn(context, commandWidth, primaryItems),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: image,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionColumn(BuildContext context, double commandWidth,
      List<CommandBarItem> primaryItems) {
    return Column(
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
              child: SizedBox(
                width: commandWidth,
                child: CommandBarCard(
                  child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.clip,
                    primaryItems: primaryItems,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Text(element.description),
            ),
          ),
        ),
        const Expanded(
          flex: 0,
          child: SizedBox(),
        ),
        if (element.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              runSpacing: 4,
              children: [
                ...element.tags.map((e) {
                  final isBright = FluentTheme.of(context).brightness.isLight;
                  Color color = isBright ? Colors.grey : Colors.grey[40];
                  final nsfwTags = [
                    'nsfw',
                    '18+',
                    'r18',
                    '19',
                    'hentai',
                  ];
                  if (nsfwTags.contains(e.toLowerCase())) {
                    color = Colors.red;
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 10),
      ],
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
      final data = await api.download(url);
      if (!context.mounted) return;
      final length = data.length;
      final filename = element.title;
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
