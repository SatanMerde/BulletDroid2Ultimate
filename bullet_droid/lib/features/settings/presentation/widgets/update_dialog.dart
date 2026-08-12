import 'package:flutter/material.dart';
import 'package:bullet_droid/core/services/update_service.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const UpdateDialog(),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isChecking = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  UpdateInfo? _updateInfo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUpdates();
  }

  Future<void> _checkUpdates() async {
    try {
      final info = await UpdateService.checkForUpdates();
      if (mounted) {
        setState(() {
          _updateInfo = info;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (_updateInfo == null) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      await UpdateService.downloadAndInstallApk(
        _updateInfo!.downloadUrl,
        (progress) {
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: GeistColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
      ),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(GeistSpacing.xl),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isChecking) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: GeistColors.blue),
          SizedBox(height: GeistSpacing.lg),
          GeistText.bodyLarge('Checking for updates...'),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: GeistColors.red, size: 48),
          SizedBox(height: GeistSpacing.md),
          GeistText.headingMedium('Update Check Failed'),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium(_error!, customColor: GeistColors.red, textAlign: TextAlign.center),
          SizedBox(height: GeistSpacing.lg),
          GeistButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            variant: GeistButtonVariant.outline,
          ),
        ],
      );
    }

    if (_updateInfo != null && !_updateInfo!.updateAvailable) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: GeistColors.terminalGreen, size: 48),
          SizedBox(height: GeistSpacing.md),
          GeistText.headingMedium('You are up to date!'),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium('Version ${_updateInfo!.currentVersion} is the latest version.', textAlign: TextAlign.center),
          SizedBox(height: GeistSpacing.lg),
          GeistButton(
            text: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            variant: GeistButtonVariant.outline,
          ),
        ],
      );
    }

    // Update available
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.system_update, color: GeistColors.blue, size: 32),
            SizedBox(width: GeistSpacing.md),
            Expanded(
              child: GeistText.headingMedium('Update Available!'),
            ),
          ],
        ),
        SizedBox(height: GeistSpacing.lg),
        GeistText.bodyMedium(
          'A new version (${_updateInfo!.latestVersion}) is available. You are currently on ${_updateInfo!.currentVersion}.',
        ),
        SizedBox(height: GeistSpacing.md),
        Container(
          padding: EdgeInsets.all(GeistSpacing.md),
          decoration: BoxDecoration(
            color: GeistColors.gray50,
            borderRadius: BorderRadius.circular(GeistBorders.radiusMd),
            border: Border.all(color: GeistColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GeistText.bodyMedium('Release Notes:', fontWeight: FontWeight.bold),
              SizedBox(height: GeistSpacing.sm),
              GeistText.bodySmall(_updateInfo!.releaseNotes, maxLines: 5, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        SizedBox(height: GeistSpacing.xl),
        if (_isDownloading) ...[
          LinearProgressIndicator(
            value: _downloadProgress,
            color: GeistColors.blue,
            backgroundColor: GeistColors.gray200,
          ),
          SizedBox(height: GeistSpacing.sm),
          Center(
            child: GeistText.bodyMedium('${(_downloadProgress * 100).toStringAsFixed(1)}% Downloaded'),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GeistButton(
                text: 'Later',
                onPressed: () => Navigator.of(context).pop(),
                variant: GeistButtonVariant.ghost,
              ),
              SizedBox(width: GeistSpacing.md),
              GeistButton(
                text: 'Update Now',
                onPressed: _startDownload,
                variant: GeistButtonVariant.filled,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
