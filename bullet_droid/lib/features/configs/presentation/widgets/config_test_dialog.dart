import 'package:flutter/material.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

class ConfigTestDialog extends StatefulWidget {
  final Config config;

  const ConfigTestDialog({super.key, required this.config});

  static Future<void> show(BuildContext context, Config config) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfigTestDialog(config: config),
    );
  }

  @override
  State<ConfigTestDialog> createState() => _ConfigTestDialogState();
}

class _ConfigTestDialogState extends State<ConfigTestDialog> {
  final _dataController = TextEditingController();
  final _proxyController = TextEditingController();
  bool _useProxy = false;
  ProxyType _proxyType = ProxyType.HTTP;
  
  bool _isTesting = false;
  BotData? _result;
  String? _error;

  @override
  void dispose() {
    _dataController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _error = null;
    });

    try {
      final input = _dataController.text.trim();
      
      Proxy? proxy;
      if (_useProxy && _proxyController.text.trim().isNotEmpty) {
        final parts = _proxyController.text.trim().split(':');
        if (parts.length >= 2) {
          proxy = Proxy(
            host: parts[0],
            port: int.tryParse(parts[1]) ?? 80,
            type: _proxyType,
            username: parts.length > 2 ? parts[2] : null,
            password: parts.length > 3 ? parts[3] : null,
          );
        }
      }

      final botData = BotData(
        input: input,
        useProxy: _useProxy,
        proxy: proxy,
        debugMode: true, // Force debug mode to get full logs
      );

      final result = await ExecutionEngine.execute(widget.config, botData);
      
      if (mounted) {
        setState(() {
          _result = result;
          _isTesting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isTesting = false;
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
        width: 800, // Make it wide enough to view logs comfortably
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: EdgeInsets.all(GeistSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            SizedBox(height: GeistSpacing.lg),
            Expanded(
              child: _result != null ? _buildResultsView() : _buildSetupView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GeistText.headingLarge(
          'Test Config: ${widget.config.metadata.name}',
          customColor: GeistColors.black,
        ),
        IconButton(
          icon: Icon(Icons.close, color: GeistColors.gray500),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText.bodyLarge('Data Input', fontWeight: FontWeight.w600),
          SizedBox(height: GeistSpacing.sm),
          TextField(
            controller: _dataController,
            decoration: _inputDecoration('e.g. email@example.com:password'),
          ),
          
          SizedBox(height: GeistSpacing.lg),
          
          Row(
            children: [
              Switch(
                value: _useProxy,
                onChanged: (val) => setState(() => _useProxy = val),
                activeColor: GeistColors.blue,
              ),
              SizedBox(width: GeistSpacing.sm),
              GeistText.bodyLarge('Use Proxy', fontWeight: FontWeight.w600),
            ],
          ),
          
          if (_useProxy) ...[
            SizedBox(height: GeistSpacing.sm),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _proxyController,
                    decoration: _inputDecoration('Host:Port[:User:Pass]'),
                  ),
                ),
                SizedBox(width: GeistSpacing.md),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: GeistColors.gray200),
                      borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProxyType>(
                        value: _proxyType,
                        isExpanded: true,
                        items: ProxyType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: GeistText.bodyMedium(type.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _proxyType = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          SizedBox(height: GeistSpacing.xl),
          
          if (_error != null) ...[
            Container(
              padding: EdgeInsets.all(GeistSpacing.md),
              decoration: BoxDecoration(
                color: GeistColors.errorColorSubtle,
                borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
                border: Border.all(color: GeistColors.red.withValues(alpha: 0.3)),
              ),
              child: GeistText.bodyMedium(_error!, customColor: GeistColors.red),
            ),
            SizedBox(height: GeistSpacing.lg),
          ],
          
          SizedBox(
            width: double.infinity,
            child: GeistButton(
              text: _isTesting ? 'Testing...' : 'Run Test',
              onPressed: _isTesting ? () {} : _runTest,
              variant: GeistButtonVariant.filled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final statusColor = _getStatusColor(_result!.status);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status header
        Container(
          padding: EdgeInsets.all(GeistSpacing.lg),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              GeistText.headingMedium('Status: ', fontWeight: FontWeight.bold),
              GeistText.headingMedium(
                _result!.status.name.toUpperCase(), 
                customColor: statusColor,
                fontWeight: FontWeight.bold,
              ),
              Spacer(),
              GeistButton(
                text: 'Test Again',
                onPressed: () => setState(() => _result = null),
                variant: GeistButtonVariant.outline,
                size: GeistButtonSize.small,
              ),
            ],
          ),
        ),
        
        SizedBox(height: GeistSpacing.lg),
        
        // Captures
        if (_result!.variables.getAll().isNotEmpty) ...[
          GeistText.headingMedium('Captures', fontWeight: FontWeight.w600),
          SizedBox(height: GeistSpacing.sm),
          Container(
            padding: EdgeInsets.all(GeistSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: GeistColors.gray200),
              borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _result!.variables.getAll().map((v) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GeistText.bodyMedium(v.name, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        flex: 2,
                        child: GeistText.bodyMedium(v.toString(), customColor: GeistColors.gray500),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: GeistSpacing.lg),
        ],
        
        // Logs
        GeistText.headingMedium('Execution Log', fontWeight: FontWeight.w600),
        SizedBox(height: GeistSpacing.sm),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(GeistSpacing.md),
            decoration: BoxDecoration(
              color: GeistColors.gray800, // Dark terminal-like background
              borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
            ),
            child: ListView.builder(
              itemCount: _result!.logs.length,
              itemBuilder: (context, index) {
                final log = _result!.logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '[${log.level.name}] ${log.message}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: _getLogColor(log.level),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BotStatus status) {
    switch (status) {
      case BotStatus.SUCCESS:
        return GeistColors.terminalGreen;
      case BotStatus.CUSTOM:
        return GeistColors.amber;
      case BotStatus.FAIL:
      case BotStatus.BAN:
      case BotStatus.ERROR:
        return GeistColors.red;
      case BotStatus.RETRY:
        return GeistColors.gray500;
      default:
        return GeistColors.gray400;
    }
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.ERROR:
        return Colors.redAccent;
      case LogLevel.WARNING:
        return Colors.orangeAccent;
      case LogLevel.INFO:
        return Colors.lightBlueAccent;
      case LogLevel.DEBUG:
      default:
        return Colors.grey;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: GeistColors.gray400),
      filled: true,
      fillColor: GeistColors.gray50,
      contentPadding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.md,
        vertical: GeistSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
        borderSide: BorderSide(color: GeistColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
        borderSide: BorderSide(color: GeistColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
        borderSide: BorderSide(color: GeistColors.blue),
      ),
    );
  }
}
