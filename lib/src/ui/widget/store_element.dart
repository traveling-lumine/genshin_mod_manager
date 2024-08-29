import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../backend/akasha/domain/entity/nahida_element.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/nahida_store.dart';
import '../util/open_url.dart';
import 'intrinsic_command_bar.dart';

class StoreElement extends ConsumerWidget {
  const StoreElement({
    required this.element,
    required this.category,
    required this.passwordController,
    super.key,
  });
  final TextEditingController passwordController;

  final NahidaliveElement element;
  final ModCategory category;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final buttons = <CommandBarItem>[];
    final virusTotalUrl = element.virustotalUrl;
    if (virusTotalUrl != null && virusTotalUrl.isNotEmpty) {
      buttons.add(
        CommandBarButton(
          onPressed: () => openUrl(virusTotalUrl),
          icon: const Icon(FluentIcons.shield_alert),
        ),
      );
    }
    final arcaUrl = element.arcaUrl;
    if (arcaUrl != null && arcaUrl.isNotEmpty) {
      buttons.add(
        CommandBarButton(
          onPressed: () => openUrl(arcaUrl),
          icon: const ImageIcon(
            AssetImage('images/arca_logo.png'),
          ),
        ),
      );
    }
    buttons.add(
      CommandBarButton(
        onPressed: () => unawaited(
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (final dialogContext) =>
                _downloadDialog(dialogContext, context, ref),
          ),
        ),
        icon: const Icon(FluentIcons.download),
      ),
    );
    return Card(
      child: Column(
        children: [
          Expanded(
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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TextEditingController>(
          'passwordController',
          passwordController,
        ),
      )
      ..add(DiagnosticsProperty<NahidaliveElement>('element', element))
      ..add(DiagnosticsProperty<ModCategory>('category', category));
  }

  Widget _buildDescriptionColumn(
    final BuildContext context,
    final List<CommandBarItem> primaryItems,
  ) {
    final description = element.description;
    final bodyStyle = FluentTheme.of(context).typography.body;
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
              child: description != null
                  ? SelectableText(description)
                  : SelectableText.rich(
                      TextSpan(
                        text: 'No description',
                        style: bodyStyle?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: bodyStyle.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
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
                ...element.tags.map((final e) {
                  final isBright = FluentTheme.of(context).brightness.isLight;
                  var color = isBright ? Colors.grey : Colors.grey[40];
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

  Widget _buildPreview(final BuildContext context) => Center(
        child: GestureDetector(
          onTap: () => unawaited(
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (final dialogContext) => GestureDetector(
                onTap: Navigator.of(dialogContext).pop,
                onSecondaryTap: Navigator.of(dialogContext).pop,
                child: CachedNetworkImage(
                  imageUrl: element.previewUrl,
                  progressIndicatorBuilder:
                      (final context, final url, final progress) =>
                          Center(child: ProgressRing(value: progress.progress)),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          child: CachedNetworkImage(
            imageUrl: element.previewUrl,
            fit: BoxFit.contain,
            progressIndicatorBuilder:
                (final context, final url, final progress) =>
                    ProgressRing(value: progress.progress),
            errorWidget: (final context, final url, final error) =>
                const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FluentIcons.error),
                SelectableText('Failed to load'),
              ],
            ),
          ),
        ),
      );

  Widget _downloadDialog(
    final BuildContext dialogContext,
    final BuildContext context,
    final WidgetRef ref,
  ) =>
      ContentDialog(
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
              unawaited(
                ref
                    .read(downloadModelProvider)
                    .onModDownload(element: element, category: category),
              );
            },
            child: const Text('Download'),
          ),
        ],
      );
}
