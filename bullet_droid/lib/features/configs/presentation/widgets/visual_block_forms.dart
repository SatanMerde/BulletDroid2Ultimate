import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/features/configs/models/visual_blocks.dart';

class RequestBlockForm extends StatefulWidget {
  final RequestBlockUI block;
  final VoidCallback onChanged;

  const RequestBlockForm({super.key, required this.block, required this.onChanged});

  @override
  State<RequestBlockForm> createState() => _RequestBlockFormState();
}

class _RequestBlockFormState extends State<RequestBlockForm> {
  late TextEditingController _urlController;
  late TextEditingController _postDataController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.block.url);
    _postDataController = TextEditingController(text: widget.block.postData);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _postDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DropdownButton<String>(
              value: widget.block.method,
              items: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => widget.block.method = val);
                  widget.onChanged();
                }
              },
            ),
            SizedBox(width: GeistSpacing.sm),
            Expanded(
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'URL',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  widget.block.url = val;
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
        if (widget.block.method == 'POST' || widget.block.method == 'PUT') ...[
          SizedBox(height: GeistSpacing.md),
          TextField(
            controller: _postDataController,
            decoration: InputDecoration(
              labelText: 'POST Data',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (val) {
              widget.block.postData = val;
              widget.onChanged();
            },
          ),
        ],
      ],
    );
  }
}

class KeycheckBlockForm extends StatefulWidget {
  final KeycheckBlockUI block;
  final VoidCallback onChanged;

  const KeycheckBlockForm({super.key, required this.block, required this.onChanged});

  @override
  State<KeycheckBlockForm> createState() => _KeycheckBlockFormState();
}

class _KeycheckBlockFormState extends State<KeycheckBlockForm> {
  Widget _buildKeychainEditor(String title, List<String> keys) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GeistText.bodyMedium(title, fontWeight: FontWeight.bold),
            IconButton(
              icon: Icon(Icons.add_circle_outline, size: 20),
              onPressed: () {
                setState(() => keys.add(''));
                widget.onChanged();
              },
            ),
          ],
        ),
        ...keys.asMap().entries.map((entry) {
          final idx = entry.key;
          final val = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: val,
                    decoration: InputDecoration(
                      hintText: 'Match string',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      keys[idx] = v;
                      widget.onChanged();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: GeistColors.red, size: 20),
                  onPressed: () {
                    setState(() => keys.removeAt(idx));
                    widget.onChanged();
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildKeychainEditor('SUCCESS Keychain', widget.block.successKeys),
        _buildKeychainEditor('FAIL Keychain', widget.block.failKeys),
        _buildKeychainEditor('BAN Keychain', widget.block.banKeys),
        _buildKeychainEditor('RETRY Keychain', widget.block.retryKeys),
      ],
    );
  }
}

class ParseBlockForm extends StatefulWidget {
  final ParseBlockUI block;
  final VoidCallback onChanged;

  const ParseBlockForm({super.key, required this.block, required this.onChanged});

  @override
  State<ParseBlockForm> createState() => _ParseBlockFormState();
}

class _ParseBlockFormState extends State<ParseBlockForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.block.varName,
                decoration: InputDecoration(
                  labelText: 'Variable Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) {
                  widget.block.varName = v;
                  widget.onChanged();
                },
              ),
            ),
            SizedBox(width: GeistSpacing.md),
            Row(
              children: [
                Checkbox(
                  value: widget.block.isRegex,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => widget.block.isRegex = v);
                      widget.onChanged();
                    }
                  },
                ),
                GeistText.bodyMedium('Regex'),
              ],
            ),
          ],
        ),
        SizedBox(height: GeistSpacing.md),
        TextFormField(
          initialValue: widget.block.leftString,
          decoration: InputDecoration(
            labelText: widget.block.isRegex ? 'Regex Pattern' : 'Left String',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (v) {
            widget.block.leftString = v;
            widget.onChanged();
          },
        ),
        if (!widget.block.isRegex) ...[
          SizedBox(height: GeistSpacing.md),
          TextFormField(
            initialValue: widget.block.rightString,
            decoration: InputDecoration(
              labelText: 'Right String',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) {
              widget.block.rightString = v;
              widget.onChanged();
            },
          ),
        ]
      ],
    );
  }
}
