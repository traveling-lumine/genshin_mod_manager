import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../backend/nahida/domain/entity/nahida_element.dart';
import '../../backend/structure/entity/mod_category.dart';
import '../../di/nahida_download_queue.dart';
import '../util/open_url.dart';
import 'intrinsic_command_bar.dart';

class StoreElement extends ConsumerWidget {
  const StoreElement({
    required this.element,
    required this.category,
    super.key,
  });
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
          icon: const ImageIcon(AssetImage('images/arca_logo.png')),
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
                _showDownloadDialog(dialogContext, context, ref),
          ),
        ),
        icon: const Icon(FluentIcons.download),
      ),
    );
    return Card(
      child: Column(
        children: [
          Expanded(child: _buildDescriptionColumn(context, buttons)),
          const SizedBox(height: 10),
          Expanded(flex: 2, child: _buildPreview(context)),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
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
        _buildHeader(context, primaryItems),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          _buildModDescription(description, context, bodyStyle),
                    ),
                    if (element.tags.isNotEmpty) _buildTags(context),
                  ],
                ),
              ),
              _buildExpiresAt(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiresAt(final BuildContext context) {
    final expiresAtDateTime = element.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(element.expiresAt! * 1000)
        : null;
    final dateFormater = DateFormat('yyyy-MM-dd\nHH:mm:ss');
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // This is a hack to make the column not shrink when the text is
          // the infinite symbol
          const Visibility.maintain(visible: false, child: Text('2099-12-31')),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.calendar),
              const SizedBox(width: 4),
              Text(
                expiresAtDateTime != null
                    ? dateFormater.format(expiresAtDateTime)
                    : '∞',
                textAlign: TextAlign.center,
                style: expiresAtDateTime == null
                    ? FluentTheme.of(context).typography.bodyLarge
                    : null,
              ),
              Visibility.maintain(
                visible: expiresAtDateTime != null &&
                    expiresAtDateTime.difference(DateTime.now()).inDays < 7,
                child: Text(
                  'Expires soon!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    final BuildContext context,
    final List<CommandBarItem> primaryItems,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (element.password)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'Password protected',
                child: Icon(FluentIcons.lock),
              ),
            ),
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
      );

  Widget _buildModDescription(
    final String? description,
    final BuildContext context,
    final TextStyle? bodyStyle,
  ) =>
      SingleChildScrollView(
        child: description != null
            ? SelectableText(description)
            : SelectableText.rich(
                TextSpan(
                  text: AppLocalizations.of(context)!.noDescription,
                  style: bodyStyle?.copyWith(
                    fontStyle: AppLocalizations.of(context)!.localeName == 'ko'
                        ? null
                        : FontStyle.italic,
                    color: bodyStyle.color?.withOpacity(0.5),
                  ),
                ),
              ),
      );

  Widget _buildPreview(final BuildContext context) {
    final imageProvider = CachedNetworkImageProvider(element.previewUrl);
    return Center(
      child: Stack(
        children: [
          SizedBox.expand(
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                  child: Image(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () async => _showImageDialog(context, imageProvider),
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(final BuildContext context) => Padding(
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
                  border: Border.all(color: color),
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
      );

  Widget _showDownloadDialog(
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
                    .read(nahidaDownloadQueueProvider.notifier)
                    .addDownload(element: element, category: category),
              );
            },
            child: const Text('Download'),
          ),
        ],
      );

  Future<void> _showImageDialog(
    final BuildContext context,
    final ImageProvider image,
  ) =>
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (final dialogContext) => GestureDetector(
          onTap: Navigator.of(dialogContext).pop,
          onSecondaryTap: Navigator.of(dialogContext).pop,
          child: Image(image: image, fit: BoxFit.contain),
        ),
      );
}
