import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/features/configs/models/visual_blocks.dart';
import 'package:bullet_droid/features/configs/presentation/widgets/visual_block_forms.dart';

class VisualBlockCard extends StatefulWidget {
  final VisualBlock block;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const VisualBlockCard({
    super.key,
    required this.block,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<VisualBlockCard> createState() => _VisualBlockCardState();
}

class _VisualBlockCardState extends State<VisualBlockCard> {
  bool _isExpanded = false;

  IconData _getIcon() {
    switch (widget.block.type) {
      case VisualBlockType.request:
        return Icons.language;
      case VisualBlockType.keycheck:
        return Icons.vpn_key;
      case VisualBlockType.parse:
        return Icons.code;
    }
  }

  Color _getColor() {
    switch (widget.block.type) {
      case VisualBlockType.request:
        return GeistColors.blue;
      case VisualBlockType.keycheck:
        return GeistColors.amber;
      case VisualBlockType.parse:
        return GeistColors.black;
    }
  }

  String _getTitle() {
    switch (widget.block.type) {
      case VisualBlockType.request:
        return 'REQUEST';
      case VisualBlockType.keycheck:
        return 'KEYCHECK';
      case VisualBlockType.parse:
        return 'PARSE';
    }
  }

  String _getSubtitle() {
    switch (widget.block.type) {
      case VisualBlockType.request:
        final b = widget.block as RequestBlockUI;
        return '${b.method} ${b.url}';
      case VisualBlockType.keycheck:
        final b = widget.block as KeycheckBlockUI;
        final total = b.successKeys.length + b.failKeys.length + b.banKeys.length + b.retryKeys.length;
        return '$total keys configured';
      case VisualBlockType.parse:
        final b = widget.block as ParseBlockUI;
        return '-> ${b.varName}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
        side: BorderSide(color: GeistColors.gray200),
      ),
      color: GeistColors.white,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColor().withValues(alpha: 0.1),
              child: Icon(_getIcon(), color: _getColor(), size: 20),
            ),
            title: GeistText.bodyLarge(_getTitle(), fontWeight: FontWeight.bold),
            subtitle: GeistText.bodySmall(_getSubtitle(), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: GeistColors.red),
                  onPressed: widget.onDelete,
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
                Icon(Icons.drag_indicator, color: GeistColors.gray400),
              ],
            ),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(GeistSpacing.lg).copyWith(top: 0),
              child: _buildForm(),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    switch (widget.block.type) {
      case VisualBlockType.request:
        return RequestBlockForm(block: widget.block as RequestBlockUI, onChanged: widget.onChanged);
      case VisualBlockType.keycheck:
        return KeycheckBlockForm(block: widget.block as KeycheckBlockUI, onChanged: widget.onChanged);
      case VisualBlockType.parse:
        return ParseBlockForm(block: widget.block as ParseBlockUI, onChanged: widget.onChanged);
    }
  }
}
