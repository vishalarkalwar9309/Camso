import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

import 'ag_pressure_calculator_screen.dart';
import 'tkph_calculator_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: AppColors.blue,
              padding: const EdgeInsets.all(20),
              child: Text(
                'CALCULATORS',
                style: AppTypography.heading(
                  26,
                  color: Colors.white,
                  weight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select a calculator',
                style: AppTypography.heading(
                  18,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _CalculatorTile(
              title: 'AG Pressure Calculator',
              subtitle: 'Calculate agricultural tyre pressure.',
              icon: Icons.speed_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AgPressureCalculatorScreen(),
                  ),
                );
              },
            ),
            _CalculatorTile(
              title: 'TKPH Calculator',
              subtitle: 'Calculate tonne-kilometres per hour.',
              icon: Icons.calculate_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const TkphCalculatorScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CalculatorTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 32,
          color: AppColors.blue,
        ),
        title: Text(
          title,
          style: AppTypography.body(
            15,
            weight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: AppTypography.body(
              12,
              color: AppColors.muted,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}