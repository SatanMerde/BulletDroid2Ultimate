import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: AppBar(
        backgroundColor: GeistColors.white,
        title: GeistText.headingLarge('Analytics Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: GeistColors.blue),
            SizedBox(height: GeistSpacing.lg),
            GeistText.headingMedium('Coming in v2.4.0'),
            SizedBox(height: GeistSpacing.md),
            GeistText.bodyMedium(
              'Detailed graphs for CPM, proxy health, and lifetime hits\nare currently being developed.',
              customColor: GeistColors.gray600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
