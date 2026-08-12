import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';

class ConfigEditorScreen extends ConsumerStatefulWidget {
  const ConfigEditorScreen({super.key});

  @override
  ConsumerState<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends ConsumerState<ConfigEditorScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

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
      body: Container(
        color: GeistColors.gray50,
        padding: EdgeInsets.all(GeistSpacing.md),
        child: Container(
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
        ),
      ),
    );
  }
}
