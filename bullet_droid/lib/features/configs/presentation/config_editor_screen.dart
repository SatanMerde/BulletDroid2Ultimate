import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/configs/models/visual_blocks.dart';
import 'package:bullet_droid/features/configs/presentation/widgets/visual_block_card.dart';

class ConfigEditorScreen extends ConsumerStatefulWidget {
  const ConfigEditorScreen({super.key});

  @override
  ConsumerState<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends ConsumerState<ConfigEditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;
  
  bool _isVisualMode = false;
  final List<VisualBlock> _visualBlocks = [];

  @override
  void initState() {
    super.initState();
    // Default template
    _codeController.text = '''[SETTINGS]
{
  "Name": "New Config",
  "SuggestedBots": 10,
  "MaxCPM": 0,
  "LastModified": "2024-01-01T00:00:00.0000000Z",
  "AdditionalInfo": "",
  "RequiredPlugins": [],
  "Author": "Anonymous",
  "Version": "1.2.2",
  "SaveEmptyCaptures": false,
  "ContinueOnCustom": false,
  "SaveHitsToTextFile": false,
  "IgnoreResponseErrors": false,
  "MaxRedirects": 8,
  "NeedsProxies": false,
  "OnlySocks": false,
  "OnlySsl": false,
  "MaxProxyUses": 0,
  "BanProxyAfterGoodStatus": false,
  "BanLoopEvasionOverride": -1,
  "EncodeData": false,
  "AllowedWordlist1": "",
  "AllowedWordlist2": "",
  "DataRules": [],
  "CustomInputs": [],
  "CaptchaUrl": "",
  "IsBase64": false,
  "FilterList": [],
  "EvaluateMathOCR": false,
  "SecurityProtocol": 0,
  "ForceHeadless": false,
  "AlwaysOpen": false,
  "AlwaysQuit": false,
  "QuitOnBanRetry": false,
  "AcceptInsecureCertificates": true,
  "WgThroughDesktop": false,
  "WgClientId": "",
  "CustomUserAgent": "",
  "RandomUA": false,
  "CustomCMDArgs": "",
  "Title": "New Config",
  "IconPath": "IconTemplate.ico",
  "LicenseSource": null,
  "Message": null,
  "MessageColor": null,
  "HitInfoFormat": "[{hit.Type}][{hit.Proxy}] {hit.Data} - [{hit.CapturedString}]",
  "AuthorColor": null,
  "WordlistColor": null,
  "BotsColor": null,
  "CustomInputColor": null,
  "CPMColor": null,
  "ProgressColor": null,
  "HitsColor": null,
  "CustomColor": null,
  "ToCheckColor": null,
  "FailsColor": null,
  "RetriesColor": null,
  "OcrRateColor": null,
  "ProxiesColor": null
}

[SCRIPT]
// Add your LoliCode here
''';
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    final filenameController = TextEditingController(text: 'NewConfig');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GeistColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
          ),
          title: GeistText.headingMedium('Save Config'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GeistText.bodyMedium('Enter a filename for your config:'),
              SizedBox(height: GeistSpacing.md),
              TextField(
                controller: filenameController,
                decoration: InputDecoration(
                  hintText: 'e.g. MyConfig',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
                    borderSide: BorderSide(color: GeistColors.blue),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: GeistText.bodyMedium('Cancel'),
            ),
            GeistButton(
              text: 'Save',
              variant: GeistButtonVariant.filled,
              onPressed: () {
                final filename = filenameController.text.trim();
                if (filename.isNotEmpty) {
                  Navigator.of(context).pop();
                  _saveConfig(filename);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveConfig(String filename) async {
    setState(() => _isSaving = true);
    
    try {
      await ref.read(configsProvider.notifier).createAndLoadConfig(
        _codeController.text, 
        filename,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: GeistText.bodyMedium('Config saved successfully!', customColor: GeistColors.white),
            backgroundColor: GeistColors.terminalGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: GeistText.bodyMedium('Failed to save: ${e.toString()}', customColor: GeistColors.white),
            backgroundColor: GeistColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _extractSettings(String code) {
    final idx = code.indexOf('[SCRIPT]');
    if (idx != -1) {
      return code.substring(0, idx).trim();
    }
    return '';
  }

  void _toggleMode(bool visual) {
    if (_isVisualMode == visual) return;
    
    if (!visual) {
      // Compile visual blocks back to code
      final compiled = VisualConfigCompiler.compileBlocks(_visualBlocks, _extractSettings(_codeController.text));
      _codeController.text = compiled;
    }
    
    setState(() => _isVisualMode = visual);
  }

  void _showAddBlockModal() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: GeistColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GeistBorders.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GeistSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GeistText.headingMedium('Add Block', fontWeight: FontWeight.bold),
              SizedBox(height: GeistSpacing.md),
              ListTile(
                leading: Icon(Icons.language, color: GeistColors.blue),
                title: GeistText.bodyLarge('REQUEST'),
                subtitle: GeistText.bodySmall('Send HTTP requests'),
                onTap: () {
                  setState(() => _visualBlocks.add(RequestBlockUI()));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.vpn_key, color: GeistColors.amber),
                title: GeistText.bodyLarge('KEYCHECK'),
                subtitle: GeistText.bodySmall('Check for success/fail keys'),
                onTap: () {
                  setState(() => _visualBlocks.add(KeycheckBlockUI()));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.code, color: GeistColors.purple),
                title: GeistText.bodyLarge('PARSE'),
                subtitle: GeistText.bodySmall('Extract variables from strings'),
                onTap: () {
                  setState(() => _visualBlocks.add(ParseBlockUI()));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GeistText.headingLarge(
          'Config Editor',
          color: GeistTextColor.primary,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: GeistSpacing.md),
            child: _isSaving
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: GeistColors.blue),
                    ),
                  )
                : GeistButton(
                    text: 'Save',
                    variant: GeistButtonVariant.filled,
                    size: GeistButtonSize.small,
                    icon: const Icon(Icons.save, size: 16),
                    onPressed: _showSaveDialog,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Toggle
          Container(
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md, vertical: GeistSpacing.sm),
            color: GeistColors.gray50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GeistButton(
                  text: 'Visual Mode',
                  variant: _isVisualMode ? GeistButtonVariant.filled : GeistButtonVariant.outline,
                  size: GeistButtonSize.small,
                  onPressed: () => _toggleMode(true),
                ),
                SizedBox(width: GeistSpacing.md),
                GeistButton(
                  text: 'LoliCode Mode',
                  variant: !_isVisualMode ? GeistButtonVariant.filled : GeistButtonVariant.outline,
                  size: GeistButtonSize.small,
                  onPressed: () => _toggleMode(false),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              color: GeistColors.gray50,
              padding: EdgeInsets.all(GeistSpacing.md),
              child: _isVisualMode ? _buildVisualEditor() : _buildTextEditor(),
            ),
          ),
        ],
      ),
      floatingActionButton: _isVisualMode 
        ? FloatingActionButton(
            onPressed: _showAddBlockModal,
            backgroundColor: GeistColors.black,
            child: Icon(Icons.add, color: GeistColors.white),
          ) 
        : null,
    );
  }

  Widget _buildTextEditor() {
    return Container(
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(color: GeistColors.gray200),
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
      ),
      child: TextField(
        controller: _codeController,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'GeistMono', // Use monospaced font
          fontSize: 13,
          color: GeistColors.black,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Paste your LoliCode here...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(GeistSpacing.md),
        ),
      ),
    );
  }

  Widget _buildVisualEditor() {
    if (_visualBlocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension_off, size: 48, color: GeistColors.gray400),
            SizedBox(height: GeistSpacing.md),
            GeistText.bodyLarge('No blocks added yet', customColor: GeistColors.gray600),
            SizedBox(height: GeistSpacing.sm),
            GeistText.bodyMedium('Tap + to add your first block', customColor: GeistColors.gray400),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: _visualBlocks.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = _visualBlocks.removeAt(oldIndex);
          _visualBlocks.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final block = _visualBlocks[index];
        return VisualBlockCard(
          key: ValueKey(block.id),
          block: block,
          onChanged: () {
            // Keep state in sync if we need parent rebuilds
          },
          onDelete: () {
            setState(() => _visualBlocks.removeAt(index));
          },
        );
      },
    );
  }
}
