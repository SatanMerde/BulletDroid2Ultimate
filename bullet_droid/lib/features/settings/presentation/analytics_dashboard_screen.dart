import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/features/hits_db/providers/hits_db_provider.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hitsState = ref.watch(hitsDbProvider);
    final proxyState = ref.watch(proxiesProvider);

    final totalHits = hitsState.hits.length;
    
    // Calculate Proxy Stats
    int goodProxies = 0;
    int badProxies = 0;
    int untestedProxies = 0;
    
    for (final proxy in proxyState.proxies) {
      switch (proxy.status.toLowerCase()) {
        case 'good':
          goodProxies++;
          break;
        case 'bad':
          badProxies++;
          break;
        default:
          untestedProxies++;
      }
    }

    return Scaffold(
      backgroundColor: GeistColors.gray100,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        title: const GeistText.headingMedium('Analytics Dashboard'),
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: GeistColors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(GeistSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Lifetime Hits',
                    totalHits.toString(),
                    Icons.check_circle,
                    GeistColors.success,
                  ),
                ),
                SizedBox(width: GeistSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Proxies',
                    proxyState.proxies.length.toString(),
                    Icons.vpn_lock,
                    GeistColors.blue,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: GeistSpacing.lg),
            
            // Proxy Health Chart
            Container(
              padding: EdgeInsets.all(GeistSpacing.lg),
              decoration: BoxDecoration(
                color: GeistColors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: GeistColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GeistText.bodyLarge('Proxy Health Distribution', fontWeight: FontWeight.bold),
                  SizedBox(height: GeistSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: proxyState.proxies.isEmpty
                        ? Center(child: GeistText.bodySmall('No proxies available', customColor: GeistColors.gray500))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                if (goodProxies > 0)
                                  PieChartSectionData(
                                    color: GeistColors.success,
                                    value: goodProxies.toDouble(),
                                    title: '$goodProxies',
                                    radius: 50,
                                    titleStyle: TextStyle(color: GeistColors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (badProxies > 0)
                                  PieChartSectionData(
                                    color: GeistColors.error,
                                    value: badProxies.toDouble(),
                                    title: '$badProxies',
                                    radius: 50,
                                    titleStyle: TextStyle(color: GeistColors.white, fontWeight: FontWeight.bold),
                                  ),
                                if (untestedProxies > 0)
                                  PieChartSectionData(
                                    color: GeistColors.gray400,
                                    value: untestedProxies.toDouble(),
                                    title: '$untestedProxies',
                                    radius: 50,
                                    titleStyle: TextStyle(color: GeistColors.white, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: GeistSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Good', GeistColors.success),
                      SizedBox(width: GeistSpacing.md),
                      _buildLegendItem('Bad', GeistColors.error),
                      SizedBox(width: GeistSpacing.md),
                      _buildLegendItem('Untested', GeistColors.gray400),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        color: GeistColors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: GeistColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          SizedBox(height: GeistSpacing.md),
          GeistText.headingMedium(value, fontWeight: FontWeight.bold),
          SizedBox(height: GeistSpacing.xs),
          GeistText.bodySmall(title, customColor: GeistColors.gray600),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: GeistSpacing.xs),
        GeistText.bodySmall(label, customColor: GeistColors.gray600),
      ],
    );
  }
}
