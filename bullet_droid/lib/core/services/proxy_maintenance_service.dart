import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/features/settings/providers/settings_provider.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';
import 'package:bullet_droid/core/utils/logging.dart';

class ProxyMaintenanceService {
  static Timer? _timer;

  static void start(Ref ref) {
    _timer?.cancel();
    
    // Check every 2 hours
    _timer = Timer.periodic(const Duration(hours: 2), (timer) async {
      final settings = ref.read(settingsProvider);
      if (!settings.enableProxyMaintenance) return;
      
      Log.i('Starting background proxy maintenance...');
      
      try {
        // Scrape and add new proxies
        final proxiesNotifier = ref.read(proxiesProvider.notifier);
        final addedCount = await proxiesNotifier.scrapeProxies();
        
        Log.i('Background proxy maintenance complete. Added $addedCount proxies.');
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
