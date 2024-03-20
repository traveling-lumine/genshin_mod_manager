import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store/nahida_store_vm.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';

import 'package:url_launcher/url_launcher.dart';

class StoreElement extends StatelessWidget {
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
  Widget build(final BuildContext context) {
    final buttons = <CommandBarItem>[];
    final virusTotalUrl = element.virustotalUrl;
    if (virusTotalUrl != null && virusTotalUrl.isNotEmpty) {
      buttons.add(
        CommandBarButton(
          onPressed: () => launchUrl(Uri.parse(virusTotalUrl)),
          icon: const Icon(FluentIcons.shield_alert),
        ),
      );
    }
    final arcaUrl = element.arcaUrl;
    if (arcaUrl != null && arcaUrl.isNotEmpty) {
      buttons.add(
        CommandBarButton(
          onPressed: () => launchUrl(Uri.parse(arcaUrl)),
          icon: const ImageIcon(
            AssetImage('images/arca_logo.png'),
          ),
        ),
      );
    }
    buttons.add(
      CommandBarButton(
        onPressed: () => showDialog(
          context: context,
          barrierDismissible: true,
          builder: (final dialogContext) =>
              _downloadDialog(dialogContext, context),
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

  Widget _buildPreview(final BuildContext context) {
    final networkImage = NetworkImage(element.previewUrl);
    // networkImage to widget
    return Center(
      child: GestureDetector(
        onTap: () => unawaited(
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (final dialogContext) => GestureDetector(
              onTap: Navigator.of(dialogContext).pop,
              onSecondaryTap: Navigator.of(dialogContext).pop,
              child: Image(
                image: networkImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        child: Image(
          image: networkImage,
          fit: BoxFit.contain,
          loadingBuilder: (final context, final child, final loadingProgress) {
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
          errorBuilder: (final context, final error, final stackTrace) =>
              Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.error),
              Text('Failed to load image: ${error.runtimeType}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionColumn(
    final BuildContext context,
    final List<CommandBarItem> primaryItems,
  ) =>
      Column(
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

  Widget _downloadDialog(
    final BuildContext dialogContext,
    final BuildContext context,
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
              final vm = context.read<NahidaStoreViewModel>();
              unawaited(
                vm.onModDownload(
                  element: element,
                  category: category,
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      );

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
}
