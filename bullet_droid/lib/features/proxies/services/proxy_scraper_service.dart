import 'package:http/http.dart' as http;
import 'package:bullet_droid/features/proxies/models/proxy_model.dart';
import 'package:bullet_droid/core/utils/logging.dart';

class ProxyScraperService {
  static const String _baseUrl = 'https://api.proxyscrape.com/v2/?request=displayproxies&timeout=10000&country=all&ssl=all&anonymity=all';

  /// Scrapes free proxies from ProxyScrape for HTTP, SOCKS4, and SOCKS5.
  Future<List<ProxyModel>> scrapeAllProxies() async {
    final List<ProxyModel> allProxies = [];
    
    try {
      // Scrape HTTP
      final httpProxies = await _scrapeProtocol('http', ProxyType.http);
      allProxies.addAll(httpProxies);
      
      // Scrape SOCKS4
      final socks4Proxies = await _scrapeProtocol('socks4', ProxyType.socks4);
      allProxies.addAll(socks4Proxies);
      
      // Scrape SOCKS5
      final socks5Proxies = await _scrapeProtocol('socks5', ProxyType.socks5);
      allProxies.addAll(socks5Proxies);
      
    } catch (e) {
      Log.e('Failed to scrape proxies: $e');
      throw Exception('Failed to scrape proxies from ProxyScrape. Please check your connection.');
    }
    
    return allProxies;
  }

  Future<List<ProxyModel>> _scrapeProtocol(String protocolString, ProxyType type) async {
    final url = Uri.parse('$_baseUrl&protocol=$protocolString');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final lines = response.body.split(RegExp(r'\r?\n'));
      final List<ProxyModel> parsedProxies = [];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        
        final parts = trimmed.split(':');
        if (parts.length == 2) {
          final address = parts[0];
          final port = int.tryParse(parts[1]);
          
          if (port != null) {
            parsedProxies.add(
              ProxyModel(
                address: address,
                port: port,
                type: type,
                status: ProxyStatus.untested,
              ),
            );
          }
        }
      }
      return parsedProxies;
    } else {
      Log.w('Failed to load $protocolString proxies from ProxyScrape (Status ${response.statusCode})');
      return [];
    }
  }
}
