import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/features/settings/providers/settings_provider.dart';
import 'package:bullet_droid/features/proxies/providers/proxy_scraper_provider.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';
import 'package:bullet_droid/core/utils/logging.dart';

class ProxyMaintenanceService {
  static Timer? _timer;

  static void start(WidgetRef ref) {
    _timer?.cancel();
    
    // Check every 2 hours
    _timer = Timer.periodic(const Duration(hours: 2), (timer) async {
      final settings = ref.read(settingsProvider);
      if (!settings.enableProxyMaintenance) return;
      
      Log.i('Starting background proxy maintenance...');
      
      try {
        // 1. Scrape new proxies
        final scraperNotifier = ref.read(proxyScraperProvider.notifier);
        await scraperNotifier.scrapeProxies(
          protocol: 'http',
          timeoutMs: 10000,
        );
        
        final scrapedProxies = ref.read(proxyScraperProvider).scrapedProxies;
        if (scrapedProxies.isNotEmpty) {
          // 2. Add them to default list
          final proxiesNotifier = ref.read(proxiesProvider.notifier);
          await proxiesNotifier.addProxiesFromList(
            'default_list', // Assuming a default list ID, or just create one if not exists.
            scrapedProxies.map((p) => '${p.ip}:${p.port}').toList(),
          );
        }
        
        Log.i('Background proxy maintenance complete. Added ${scrapedProxies.length} proxies.');
      } catch (e) {
        Log.e('Proxy maintenance failed: $e');
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
