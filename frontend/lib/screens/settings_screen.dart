import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'about_screen.dart';
import 'error_screen.dart';
import 'language_screen.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  // ================================================================
  // NOTIFICATION SETTINGS
  // ================================================================

  bool productUpdates = true;
  bool technicalBulletins = true;
  bool promotions = false;
  bool dealerAlerts = true;

  // ================================================================
  // PRIVACY SETTINGS
  // ================================================================

  bool usageAnalytics = true;
  bool crashReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: AppTypography.heading(
            24,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // ==========================================================
          // NOTIFICATIONS
          // ==========================================================

          _sectionLabel('NOTIFICATIONS'),

          const SizedBox(height: 8),

          _settingsCard(
            children: [
              _toggleTile(
                title: 'Product Updates',
                subtitle:
                    'New products and updates',
                value: productUpdates,
                onChanged: (value) {
                  setState(() {
                    productUpdates = value;
                  });
                },
                showBorder: true,
              ),

              _toggleTile(
                title: 'Technical Bulletins',
                subtitle:
                    'Important safety notices',
                value: technicalBulletins,
                onChanged: (value) {
                  setState(() {
                    technicalBulletins = value;
                  });
                },
                showBorder: true,
              ),

              _toggleTile(
                title: 'Promotions',
                subtitle:
                    'Fleet programs and offers',
                value: promotions,
                onChanged: (value) {
                  setState(() {
                    promotions = value;
                  });
                },
                showBorder: true,
              ),

              _toggleTile(
                title: 'Dealer Alerts',
                subtitle:
                    'Nearby dealer events',
                value: dealerAlerts,
                onChanged: (value) {
                  setState(() {
                    dealerAlerts = value;
                  });
                },
                showBorder: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // PRIVACY
          // ==========================================================

          _sectionLabel('PRIVACY'),

          const SizedBox(height: 8),

          _settingsCard(
            children: [
              _toggleTile(
                title: 'Usage Analytics',
                subtitle:
                    'Help improve the app',
                value: usageAnalytics,
                onChanged: (value) {
                  setState(() {
                    usageAnalytics = value;
                  });
                },
                showBorder: true,
              ),

              _toggleTile(
                title: 'Crash Reports',
                subtitle:
                    'Send crash data automatically',
                value: crashReports,
                onChanged: (value) {
                  setState(() {
                    crashReports = value;
                  });
                },
                showBorder: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // APPLICATION
          // ==========================================================

          _sectionLabel('APPLICATION'),

          const SizedBox(height: 8),

          _settingsCard(
            children: [
              _navigationTile(
                context,
                title: 'Language',
                value: 'English',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LanguageScreen(),
                    ),
                  );
                },
                showBorder: true,
              ),

              _navigationTile(
                context,
                title: 'About CAMSO',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AboutScreen(),
                    ),
                  );
                },
                showBorder: true,
              ),

              _navigationTile(
                context,
                title: 'Terms of Use',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LegalScreen(),
                    ),
                  );
                },
                showBorder: true,
              ),

              _navigationTile(
                context,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const LegalScreen(),
                    ),
                  );
                },
                showBorder: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // DIAGNOSTICS & SYSTEM STATUS
          // ==========================================================

          _sectionLabel('SYSTEM & CONNECTION STATUS'),

          const SizedBox(height: 8),

          _settingsCard(
            children: [
              _navigationTile(
                context,
                title: 'No Internet / Offline Screen',
                value: 'Preview',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ErrorScreen.noInternet(),
                    ),
                  );
                },
                showBorder: true,
              ),
              _navigationTile(
                context,
                title: 'Server Error Screen (503)',
                value: 'Preview',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ErrorScreen.serverError(),
                    ),
                  );
                },
                showBorder: true,
              ),
              _navigationTile(
                context,
                title: 'General Error Screen',
                value: 'Preview',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ErrorScreen(),
                    ),
                  );
                },
                showBorder: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==========================================================
          // VERSION / APP INFO
          // ==========================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.border,
              ),
            ),

            child: Column(
              children: [
                Text(
                  'CAMSO by CEAT',

                  style: AppTypography.body(
                    14,
                    color: AppColors.blue,
                    weight: FontWeight.w600,
                  ).copyWith(
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Version 1.0.0 (Build 100)',

                  style: AppTypography.body(
                    11,
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '© 2024 CEAT Limited. All rights reserved.',

                  textAlign: TextAlign.center,

                  style: AppTypography.body(
                    11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================================================================
  // SECTION LABEL
  // ================================================================

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
      ),

      child: Text(
        title,

        style: AppTypography.body(
          11,
          color: AppColors.muted,
          weight: FontWeight.w700,
        ).copyWith(
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ================================================================
  // SETTINGS CARD
  // ================================================================

  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: children,
      ),
    );
  }

  // ================================================================
  // TOGGLE TILE
  // ================================================================

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showBorder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),

      decoration: BoxDecoration(
        border: showBorder
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFF2F4F8),
                ),
              )
            : null,
      ),

      child: Row(
        children: [
          // ----------------------------------------------------------
          // TEXT
          // ----------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: AppTypography.body(
                    13,
                    color:
                        const Color(0xFF333333),
                    weight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,

                  style: AppTypography.body(
                    11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ----------------------------------------------------------
          // TOGGLE
          // ----------------------------------------------------------

          GestureDetector(
            onTap: () {
              onChanged(!value);
            },

            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),

              width: 48,
              height: 24,

              padding:
                  const EdgeInsets.all(2),

              decoration: BoxDecoration(
                color: value
                    ? AppColors.blue
                    : AppColors.border,

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: AnimatedAlign(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),

                alignment: value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,

                child: Container(
                  width: 20,
                  height: 20,

                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color(0x22000000),
                        blurRadius: 3,
                        offset:
                            Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NAVIGATION TILE
  // ================================================================

  Widget _navigationTile(
    BuildContext context, {
    required String title,
    String? value,
    required VoidCallback onTap,
    required bool showBorder,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

          decoration: BoxDecoration(
            border: showBorder
                ? const Border(
                    bottom: BorderSide(
                      color:
                          Color(0xFFF2F4F8),
                    ),
                  )
                : null,
          ),

          child: Row(
            children: [
              // ------------------------------------------------------
              // TITLE
              // ------------------------------------------------------

              Expanded(
                child: Text(
                  title,

                  style:
                      AppTypography.body(
                    13,
                    color:
                        const Color(
                      0xFF333333,
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------------
              // VALUE
              // ------------------------------------------------------

              if (value != null)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    right: 8,
                  ),

                  child: Text(
                    value,

                    style:
                        AppTypography.body(
                      11,
                      color:
                          AppColors.muted,
                    ),
                  ),
                ),

              // ------------------------------------------------------
              // ARROW
              // ------------------------------------------------------

              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}