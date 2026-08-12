import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class UpdateInfo {
  final bool updateAvailable;
  final String latestVersion;
  final String currentVersion;
  final String releaseNotes;
  final String downloadUrl;

  UpdateInfo({
    required this.updateAvailable,
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseNotes,
    required this.downloadUrl,
  });
}

class UpdateService {
  static const String _repoApiUrl =
      'https://api.github.com/repos/SatanMerde/BulletDroid2Ultimate/releases/latest';

  static Future<UpdateInfo> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = 'v${packageInfo.version.split('+').first}'; // Handle pubspec versions like 2.1.3+14

      final response = await http.get(Uri.parse(_repoApiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['tag_name'] as String;
        final releaseNotes = data['body'] as String? ?? 'No release notes available.';
        final assets = data['assets'] as List<dynamic>?;
        
        String downloadUrl = data['html_url'];
        
        if (assets != null && assets.isNotEmpty) {
          final apkAsset = assets.firstWhere(
            (asset) => (asset['name'] as String).endsWith('.apk'),
            orElse: () => null,
          );
          if (apkAsset != null) {
            downloadUrl = apkAsset['browser_download_url'] as String;
          }
        }

        final isUpdateAvailable = _isNewerVersion(currentVersion, latestVersion);

        return UpdateInfo(
          updateAvailable: isUpdateAvailable,
          latestVersion: latestVersion,
          currentVersion: currentVersion,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
        );
      }
      throw Exception('Failed to check for updates. API returned ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to check for updates: $e');
    }
  }

  static Future<void> downloadAndInstallApk(
    String url, 
    Function(double) onProgress,
  ) async {
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/BulletDroidUpdate.apk';
      
      // Delete old file if exists
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final result = await OpenFile.open(savePath);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open APK: ${result.message}');
      }
    } catch (e) {
      throw Exception('Download/Install failed: $e');
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    final cParts = current.replaceAll('v', '').split('+')[0].split('.');
    final lParts = latest.replaceAll('v', '').split('+')[0].split('.');

    for (int i = 0; i < 3; i++) {
      final cVal = i < cParts.length ? (int.tryParse(cParts[i]) ?? 0) : 0;
      final lVal = i < lParts.length ? (int.tryParse(lParts[i]) ?? 0) : 0;
      if (lVal > cVal) return true;
      if (lVal < cVal) return false;
    }
    return false;
  }
}
