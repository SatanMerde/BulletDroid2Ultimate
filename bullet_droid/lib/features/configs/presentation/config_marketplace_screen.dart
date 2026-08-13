import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/services/toast_service.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/features/configs/models/marketplace_config.dart';
import 'package:bullet_droid/features/configs/services/marketplace_service.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';

final marketplaceProvider = FutureProvider<List<MarketplaceConfig>>((ref) async {
  final service = MarketplaceService();
  return service.fetchCatalog();
});

class ConfigMarketplaceScreen extends ConsumerWidget {
  const ConfigMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketplaceState = ref.watch(marketplaceProvider);

    return Scaffold(
      backgroundColor: GeistColors.gray100,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        title: const GeistText.headingMedium('Marketplace'),
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: GeistColors.black),
      ),
      body: marketplaceState.when(
        data: (configs) {
          if (configs.isEmpty) {
            return Center(
              child: GeistText.bodyMedium('No configs available in the marketplace.', customColor: GeistColors.gray600),
            );
          }
          
          return ListView.separated(
            padding: EdgeInsets.all(GeistSpacing.md),
            itemCount: configs.length,
            separatorBuilder: (context, index) => SizedBox(height: GeistSpacing.md),
            itemBuilder: (context, index) {
              final config = configs[index];
              return _MarketplaceConfigCard(config: config);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: GeistColors.blue)),
        error: (error, stack) => Center(
          child: GeistText.bodyMedium('Failed to load marketplace: $error', customColor: GeistColors.errorColor),
        ),
      ),
    );
  }
}

class _MarketplaceConfigCard extends ConsumerStatefulWidget {
  final MarketplaceConfig config;

  const _MarketplaceConfigCard({required this.config});

  @override
  ConsumerState<_MarketplaceConfigCard> createState() => _MarketplaceConfigCardState();
}

class _MarketplaceConfigCardState extends ConsumerState<_MarketplaceConfigCard> {
  bool _isDownloading = false;

  void _downloadConfig() async {
    setState(() => _isDownloading = true);
    
    final service = MarketplaceService();
    final success = await service.downloadAndImportConfig(widget.config, ref);
    
    if (mounted) {
      setState(() => _isDownloading = false);
      if (success) {
        // Refresh local configs
        ref.invalidate(configsProvider);
        context.showSuccessToast('${widget.config.name} downloaded successfully!');
      } else {
        context.showErrorToast('Failed to download ${widget.config.name}.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        color: GeistColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GeistColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeistText.headingMedium(widget.config.name, fontWeight: FontWeight.bold),
                    SizedBox(height: GeistSpacing.xs),
                    GeistText.bodySmall('By ${widget.config.author} • v${widget.config.version}', customColor: GeistColors.gray600),
                  ],
                ),
              ),
              _isDownloading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: GeistColors.blue, strokeWidth: 2),
                    )
                  : GeistButton(
                      text: 'Download',
                      variant: GeistButtonVariant.filled,
                      onPressed: _downloadConfig,
                    ),
            ],
          ),
          SizedBox(height: GeistSpacing.md),
          GeistText.bodyMedium(widget.config.description),
          SizedBox(height: GeistSpacing.md),
          Wrap(
            spacing: GeistSpacing.sm,
            runSpacing: GeistSpacing.sm,
            children: widget.config.tags.map((tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: GeistSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: GeistColors.gray100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: GeistColors.gray200),
              ),
              child: GeistText.bodySmall('#$tag', customColor: GeistColors.gray600),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
