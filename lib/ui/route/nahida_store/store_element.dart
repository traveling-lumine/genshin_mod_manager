import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/upstream/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/category.dart';
import 'package:genshin_mod_manager/ui/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/ui/util/mod_writer.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreElement extends StatelessWidget {
  final TextEditingController passwordController;
  final NahidaliveElement element;
  final NahidaliveAPI api;
  final ModCategory category;

  const StoreElement({
    super.key,
    required this.element,
    required this.api,
    required this.category,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <CommandBarItem>[];
    final virusTotalUrl = element.virustotalUrl;
    if (virusTotalUrl != null && virusTotalUrl.isNotEmpty) {
      buttons.add(CommandBarButton(
        onPressed: () => launchUrl(Uri.parse(virusTotalUrl)),
        icon: const Icon(FluentIcons.shield_alert),
      ));
    }
    final arcaUrl = element.arcaUrl;
    if (arcaUrl != null && arcaUrl.isNotEmpty) {
      buttons.add(CommandBarButton(
        onPressed: () => launchUrl(Uri.parse(arcaUrl)),
        icon: const ImageIcon(
          AssetImage('images/arca_logo.png'),
        ),
      ));
    }
    buttons.add(CommandBarButton(
      onPressed: () => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => _downloadDialog(dialogContext, context),
      ),
      icon: const Icon(FluentIcons.download),
    ));
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: _buildDescriptionColumn(context, buttons),
          ),
          Expanded(
            flex: 2,
            child: _buildPreview(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final networkImage = NetworkImage(element.previewUrl);
    // networkImage to widget
    return Center(
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => GestureDetector(
            onTap: Navigator.of(dialogContext).pop,
            onSecondaryTap: Navigator.of(dialogContext).pop,
            child: Image(
              image: networkImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
        child: Image(
          image: networkImage,
          fit: BoxFit.contain,
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
        ),
      ),
    );
  }

  Widget _buildDescriptionColumn(
      BuildContext context, List<CommandBarItem> primaryItems) {
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
            IntrinsicCommandBarCard(
              child: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.clip,
                primaryItems: primaryItems,
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
      content: Text('This will download the mod to ${category.name}.'),
      actions: [
        Button(
          onPressed: Navigator.of(dialogContext).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            _download(
              category: category,
              onApiException: (e) => displayInfoBar(
                context,
                builder: (infoBarContext, close) => InfoBar(
                  title: const Text('Download failed'),
                  content: Text('${e.uri}'),
                  severity: InfoBarSeverity.error,
                  onClose: close,
                ),
              ),
              onDownloadComplete: (data) {
                displayInfoBar(
                  context,
                  builder: (infoBarContext, close) {
                    return InfoBar(
                      title: Text('Downloaded ${element.title}'),
                      content: Text('Length: ${data.length} bytes'),
                      severity: InfoBarSeverity.success,
                      onClose: close,
                    );
                  },
                );
                context.read<RecursiveObserverService>().forceUpdate();
              },
              onPasswordRequired: () => showDialog(
                context: context,
                builder: (dialogContext) => ContentDialog(
                  title: const Text('Enter password'),
                  content: SizedBox(
                    height: 40,
                    child: TextBox(
                      autofocus: true,
                      controller: passwordController,
                      placeholder: 'Password',
                      onSubmitted: (value) => Navigator.of(dialogContext)
                          .pop(passwordController.text),
                    ),
                  ),
                  actions: [
                    Button(
                      onPressed: Navigator.of(dialogContext).pop,
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext)
                          .pop(passwordController.text),
                      child: const Text('Download'),
                    ),
                  ],
                ),
              ),
              onExtractFail: (modName, data) async {
                unawaited(displayInfoBar(
                  context,
                  builder: (context, close) {
                    return InfoBar(
                      title: const Text('Download failed'),
                      content: Text('Failed to extract archive: decode error.'
                          ' Instead, the archive was saved as $modName.'),
                      severity: InfoBarSeverity.error,
                      onClose: close,
                    );
                  },
                ));
                try {
                  await File(category.path.pJoin(modName)).writeAsBytes(data);
                } catch (e) {
                  // duh
                }
              },
            );
          },
          child: const Text('Download'),
        ),
      ],
    );
  }

  void _download({
    required ModCategory category,
    String? pw,
    Future<String?> Function()? onPasswordRequired,
    void Function(HttpException e)? onApiException,
    void Function(Uint8List data)? onDownloadComplete,
    void Function(String modName, Uint8List data)? onExtractFail,
  }) async {
    final NahidaliveDownloadElement url;
    try {
      url = await api.downloadUrl(element.uuid, pw: pw);
    } on HttpException catch (e) {
      onApiException?.call(e);
      return;
    }
    if (!url.status) {
      final password = await onPasswordRequired?.call();
      if (password == null) return;
      return _download(
        category: category,
        onApiException: onApiException,
        onDownloadComplete: onDownloadComplete,
        onExtractFail: onExtractFail,
        onPasswordRequired: onPasswordRequired,
        pw: password,
      );
    }
    final data = await api.download(url);
    var modName = element.title;
    final awaitSuccessful = await writeModToCategory(
      category: category,
      modName: modName,
      data: data,
      onExtractFail: () => onExtractFail?.call(modName, data),
    );
    if (!awaitSuccessful) return;
    onDownloadComplete?.call(data);
  }
}
