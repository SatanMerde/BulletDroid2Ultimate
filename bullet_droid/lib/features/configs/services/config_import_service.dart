import 'package:file_picker/file_picker.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service that encapsulates config file picking and parsing.
class ConfigImportService {
  /// Open a file picker and parse the selected config.
  /// Returns null if the user cancels.
  Future<({Config config, String filePath})?> pickConfigAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path;
    if (path == null) return null;
    final config = await ConfigLoader.loadFromFile(path);
    return (config: config, filePath: path);
  }

  /// Parse a config at a known path.
  Future<Config> parseFromFile(String filePath) async {
    return ConfigLoader.loadFromFile(filePath);
  }

  /// Save raw LoliCode to a new file in the app documents directory.
  Future<String> saveConfig(String loliCode, String filename) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final configsDir = Directory('${docsDir.path}/Configs');
    if (!await configsDir.exists()) {
      await configsDir.create(recursive: true);
    }

    // Ensure the filename ends with .loli
    String finalName = filename;
    if (!finalName.toLowerCase().endsWith('.loli')) {
      finalName = '$finalName.loli';
    }

    final file = File('${configsDir.path}/$finalName');
    await file.writeAsString(loliCode);
    return file.path;
  }
}
