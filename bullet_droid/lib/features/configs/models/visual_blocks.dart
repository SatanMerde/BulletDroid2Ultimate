import 'package:flutter/foundation.dart';

enum VisualBlockType { request, keycheck, parse }

abstract class VisualBlock {
  final String id;
  VisualBlockType get type;

  VisualBlock() : id = UniqueKey().toString();

  String toLoliCode();
}

class RequestBlockUI extends VisualBlock {
  @override
  VisualBlockType get type => VisualBlockType.request;

  String url = 'https://example.com';
  String method = 'GET';
  String postData = '';
  List<Map<String, String>> customHeaders = [];

  @override
  String toLoliCode() {
    final buffer = StringBuffer();
    buffer.writeln('REQUEST $method "\$url"');
    
    if (customHeaders.isNotEmpty) {
      for (final header in customHeaders) {
        if (header.keys.first.isNotEmpty) {
          buffer.writeln('  HEADER "${header.keys.first}" : "${header.values.first}"');
        }
      }
    }
    
    if (method == 'POST' && postData.isNotEmpty) {
      buffer.writeln('  CONTENT "$postData"');
      buffer.writeln('  CONTENTTYPE "application/x-www-form-urlencoded"');
    }
    
    return buffer.toString();
  }
}

class KeycheckBlockUI extends VisualBlock {
  @override
  VisualBlockType get type => VisualBlockType.keycheck;

  List<String> successKeys = [];
  List<String> failKeys = [];
  List<String> banKeys = [];
  List<String> retryKeys = [];

  @override
  String toLoliCode() {
    final buffer = StringBuffer();
    buffer.writeln('KEYCHECK');
    
    if (successKeys.isNotEmpty) {
      buffer.writeln('  KEYCHAIN Success OR');
      for (final key in successKeys) {
        buffer.writeln('    KEY "$key"');
      }
    }
    
    if (failKeys.isNotEmpty) {
      buffer.writeln('  KEYCHAIN Failure OR');
      for (final key in failKeys) {
        buffer.writeln('    KEY "$key"');
      }
    }
    
    if (banKeys.isNotEmpty) {
      buffer.writeln('  KEYCHAIN Ban OR');
      for (final key in banKeys) {
        buffer.writeln('    KEY "$key"');
      }
    }
    
    if (retryKeys.isNotEmpty) {
      buffer.writeln('  KEYCHAIN Retry OR');
      for (final key in retryKeys) {
        buffer.writeln('    KEY "$key"');
      }
    }
    
    return buffer.toString();
  }
}

class ParseBlockUI extends VisualBlock {
  @override
  VisualBlockType get type => VisualBlockType.parse;

  String varName = 'VAR';
  String leftString = '';
  String rightString = '';
  bool isRegex = false;

  @override
  String toLoliCode() {
    if (isRegex) {
      return 'PARSE "<SOURCE>" REGEX "$leftString" -> VAR "$varName"';
    }
    return 'PARSE "<SOURCE>" LR "$leftString" "$rightString" -> VAR "$varName"';
  }
}

class VisualConfigCompiler {
  static String compileBlocks(List<VisualBlock> blocks, String existingSettings) {
    final buffer = StringBuffer();
    
    // Add existing settings back
    if (existingSettings.isNotEmpty) {
      buffer.writeln(existingSettings);
      buffer.writeln();
    }
    
    buffer.writeln('[SCRIPT]');
    
    for (final block in blocks) {
      buffer.writeln(block.toLoliCode());
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}
