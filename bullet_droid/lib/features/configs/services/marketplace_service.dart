import 'dart:convert';
import 'dart:io';
import 'package:bullet_droid/features/configs/models/marketplace_config.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:bullet_droid/features/configs/services/config_import_service.dart';
import 'package:path_provider/path_provider.dart';

class MarketplaceService {
  final String catalogUrl =
      'https://raw.githubusercontent.com/SatanMerde/BulletDroidUltimate/main/marketplace.json';
  final ConfigImportService _importService = ConfigImportService();

  Future<List<MarketplaceConfig>> fetchCatalog() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(catalogUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> jsonList = jsonDecode(responseBody);
        return jsonList.map((json) => MarketplaceConfig.fromJson(json)).toList();
      } else {
        // Fallback mock data if URL doesn't exist yet
        return _getMockCatalog();
      }
    } catch (e) {
      Log.w('Failed to fetch catalog from URL, falling back to mock: $e');
      return _getMockCatalog();
    }
  }

  Future<bool> downloadAndImportConfig(MarketplaceConfig config) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(config.downloadUrl));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${config.name}.loli');
        await response.pipe(file.openWrite());
        
        await _importService.importConfigFile(file);
        return true;
      }
      return false;
    } catch (e) {
      Log.e('Failed to download config ${config.name}: $e');
      return false;
    }
  }

  List<MarketplaceConfig> _getMockCatalog() {
    return [
      MarketplaceConfig(
        id: '1',
        name: 'Basic Auth Checker',
        author: 'Antigravity',
        description: 'A simple config to test basic authentication.',
        downloadUrl: 'https://raw.githubusercontent.com/SatanMerde/BulletDroidUltimate/main/mock_config_1.loli',
        tags: ['auth', 'test'],
        version: '1.0',
      ),
      MarketplaceConfig(
        id: '2',
        name: 'JSON API Parser',
        author: 'Antigravity',
        description: 'Advanced regex and parsing for REST APIs.',
        downloadUrl: 'https://raw.githubusercontent.com/SatanMerde/BulletDroidUltimate/main/mock_config_2.loli',
        tags: ['api', 'regex'],
        version: '1.2',
      ),
    ];
  }
}
