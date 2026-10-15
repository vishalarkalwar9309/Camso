import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/app_role.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'about_screen.dart';
import 'activity_screen.dart';
import 'admin_dashboard_screen.dart';
import 'bookmarks_screen.dart';
import 'contact_page_screen.dart';
import 'dealer_portal_screen.dart';
import 'distributor_portal_screen.dart';
import 'employee_portal_screen.dart';
import 'home_screen.dart';
import 'language_screen.dart';
import 'legal_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'oem_portal_screen.dart';
import 'product_updates_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final currentLang = languages.firstWhere(
      (l) => l['code'] == state.language,
      orElse: () => languages.first,
    );

    if (!state.loggedIn) {
      return _buildLoggedOut(context, state, currentLang);
    }

    return _buildLoggedIn(context, state, currentLang);
  }

  // ================================================================
  // LOGGED OUT / GUEST VIEW
  // ================================================================

  Widget _buildLoggedOut(
    BuildContext context,
    AppState state,
    Map<String, String> currentLang,
  ) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Sign-in Prompt Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 30,
                              color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.tr('prof_guest_title'),
                            style: AppTypography.heading(16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.tr('prof_guest_subtitle'),
                            textAlign: TextAlign.center,
                            style: AppTypography.body(11, color: AppColors.muted),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(state.tr('prof_sign_in')),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Quick Demo Role Switcher
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('TEST DIFFERENT APPLICATION ROLES'),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap any role below for instant 1-click test login:',
                                style: AppTypography.body(11, color: AppColors.muted),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _demoPill(context, state, AppRole.dealer, '🏪 Dealer'),
                                  _demoPill(context, state, AppRole.distributor, '🏭 Distributor'),
                                  _demoPill(context, state, AppRole.employee, '💼 Employee'),
                                  _demoPill(context, state, AppRole.oemPartner, '🚜 OEM Partner'),
                                  _demoPill(context, state, AppRole.admin, '⚙️ Admin'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content Menu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('CONTENT & PREFERENCES'),
                        _menuCard(
                          context,
                          items: [
                            _MenuItem(
                              label: 'Language',
                              value: currentLang['name'] ?? 'English',
                              screen: 'language',
                            ),
                            _MenuItem(
                              label: 'Saved Bookmarks',
                              value: '${state.bookmarks.length} items',
                              screen: 'bookmarks',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('MORE'),
                        _menuCard(
                          context,
                          items: const [
                            _MenuItem(label: 'About CAMSO by CEAT', screen: 'about'),
                            _MenuItem(label: 'Contact Support', screen: 'contact'),
                            _MenuItem(label: 'Legal & Privacy Notice', screen: 'legal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LOGGED IN VIEW
  // ================================================================

  Widget _buildLoggedIn(
    BuildContext context,
    AppState state,
    Map<String, String> currentLang,
  ) {
    final role = state.role;
    final initials = _getInitials(state.userDisplayName);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Profile Identity Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: AppTypography.heading(18,
                                    color: Colors.white, weight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.userDisplayName,
                                  style: AppTypography.body(14, weight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.userEmail ?? state.organizationName ?? '',
                                  style: AppTypography.body(11, color: AppColors.muted),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getRoleBadgeColor(role),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    state.roleLabel.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Quick Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            value: state.bookmarks.length.toString(),
                            label: 'Bookmarks',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BookmarksScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            context,
                            value: '${state.unreadCount}',
                            label: 'Unread Alerts',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Role-Specific Primary Portal Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildRolePortalActionCard(context, state),
                  ),

                  const SizedBox(height: 14),

                  // Activity Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _activityCard(context, state),
                  ),

                  const SizedBox(height: 18),

                  // Role Switcher Bar for Seamless Pair-Programming & Evaluation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('ROLE PREVIEW SWITCHER'),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Switch role view immediately to verify access rules:',
                                style: AppTypography.body(11, color: AppColors.muted),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _demoPill(context, state, AppRole.guest, '👤 Guest'),
                                  _demoPill(context, state, AppRole.dealer, '🏪 Dealer'),
                                  _demoPill(context, state, AppRole.distributor, '🏭 Distributor'),
                                  _demoPill(context, state, AppRole.employee, '💼 Employee'),
                                  _demoPill(context, state, AppRole.oemPartner, '🚜 OEM'),
                                  _demoPill(context, state, AppRole.admin, '⚙️ Admin'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content Menu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(state.tr('sec_system_settings')),
                        _menuCard(
                          context,
                          items: [
                            _MenuItem(
                              label: state.tr('prof_language'),
                              value: currentLang['name'] ?? 'English',
                              screen: 'language',
                            ),
                            _MenuItem(
                              label: state.tr('prof_bookmarks'),
                              value: '${state.bookmarks.length}',
                              screen: 'bookmarks',
                            ),
                            _MenuItem(
                              label: state.tr('prof_product_updates'),
                              value: 'Active',
                              screen: 'product-updates',
                            ),
                            _MenuItem(
                              label: state.tr('prof_notifications'),
                              value: '${state.unreadCount} unread',
                              screen: 'notifications',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionTitle(state.tr('sec_account_portal')),
                        _menuCard(
                          context,
                          items: [
                            _MenuItem(label: state.tr('prof_about'), screen: 'about'),
                            _MenuItem(label: state.tr('prof_contact'), screen: 'contact'),
                            _MenuItem(label: state.tr('prof_legal'), screen: 'legal'),
                            const _MenuItem(label: 'App Settings', screen: 'settings'),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => _confirmSignOut(context, state),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEE2E2),
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFFECACA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              state.tr('prof_sign_out').toUpperCase(),
                              style: AppTypography.body(12,
                                  color: const Color(0xFFEF4444),
                                  weight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 20, 14),
      color: AppColors.blue,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Home',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(
            'PROFILE',
            style: AppTypography.heading(24,
                    color: Colors.white, weight: FontWeight.w800)
                .copyWith(letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  // Primary Role Action Card
  Widget _buildRolePortalActionCard(BuildContext context, AppState state) {
    final role = state.role;
    if (role == AppRole.admin) {
      return _portalCard(
        context,
        title: 'Admin Dashboard',
        subtitle: 'Catalogue management, notifications, documents & analytics',
        icon: Icons.admin_panel_settings,
        color: AppColors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        },
      );
    }
    if (role == AppRole.employee) {
      return _portalCard(
        context,
        title: 'CEAT Employee Portal',
        subtitle: 'Internal engineering specs, training & escalation directory',
        icon: Icons.badge_outlined,
        color: AppColors.blue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmployeePortalScreen()),
          );
        },
      );
    }
    if (role == AppRole.oemPartner) {
      return _portalCard(
        context,
        title: 'OEM Partner Portal',
        subtitle: 'Chassis fitment specs, 3D CAD boundaries & Tier-1 data',
        icon: Icons.precision_manufacturing_outlined,
        color: AppColors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OemPortalScreen()),
          );
        },
      );
    }
    if (role == AppRole.dealer) {
      return _portalCard(
        context,
        title: 'Authorized Dealer Portal',
        subtitle: 'Commercial margin schedules & dealer operations',
        icon: Icons.storefront_outlined,
        color: const Color(0xFF2D52C4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DealerPortalScreen()),
          );
        },
      );
    }
    if (role == AppRole.distributor) {
      return _portalCard(
        context,
        title: 'Regional Distributor Portal',
        subtitle: 'Regional inventory allocation & supply chain support',
        icon: Icons.factory_outlined,
        color: const Color(0xFF162B6E),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DistributorPortalScreen()),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _portalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.heading(15, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTypography.body(11,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityCard(BuildContext context, AppState state) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ActivityScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart_outlined,
                    color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Activity & Saved Calculations',
                      style: AppTypography.body(13, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'History, searches, and saved pressure calculations',
                      style: AppTypography.body(10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _demoPill(
      BuildContext context, AppState state, AppRole role, String label) {
    final isCurrent = state.role == role;
    return GestureDetector(
      onTap: () {
        if (role == AppRole.guest) {
          state.continueAsGuest();
        } else {
          state.signInAsDemo(role);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${role.label} mode.'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.blue : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent ? AppColors.blue : const Color(0xFFE4E7EF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                value,
                style: AppTypography.heading(22,
                    color: AppColors.blue, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.body(10, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.body(11,
                color: AppColors.muted, weight: FontWeight.w700)
            .copyWith(letterSpacing: 1.1),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openMenuItem(context, item.screen),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  decoration: BoxDecoration(
                    border: index < items.length - 1
                        ? const Border(
                            bottom: BorderSide(color: Color(0xFFF2F4F8)))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.body(13,
                              color: const Color(0xFF333333)),
                        ),
                      ),
                      if (item.value != null && item.value!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            item.value!,
                            style: AppTypography.body(11,
                                color: AppColors.muted),
                          ),
                        ),
                      const Icon(Icons.chevron_right,
                          size: 18, color: Color(0xFFC8CEDF)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openMenuItem(BuildContext context, String screen) {
    Widget? page;
    switch (screen) {
      case 'language':
        page = const LanguageScreen();
        break;
      case 'bookmarks':
        page = const BookmarksScreen();
        break;
      case 'settings':
        page = const SettingsScreen();
        break;
      case 'about':
        page = const AboutScreen();
        break;
      case 'contact':
        page = const ContactPageScreen();
        break;
      case 'legal':
        page = const LegalScreen();
        break;
      case 'product-updates':
        page = const ProductUpdatesScreen();
        break;
      case 'notifications':
        page = const NotificationsScreen();
        break;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  void _confirmSignOut(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Log out of account?'),
        content: const Text(
          'You will return to a Guest session. Your local bookmarks will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dContext);
              state.signOut();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Color _getRoleBadgeColor(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return AppColors.blue;
      case AppRole.employee:
        return const Color(0xFF16A34A);
      case AppRole.dealer:
        return AppColors.orange;
      case AppRole.distributor:
        return const Color(0xFF2563EB);
      case AppRole.oemPartner:
        return const Color(0xFFD97706);
      case AppRole.guest:
        return const Color(0xFF6B7280);
    }
  }
}

class _MenuItem {
  final String label;
  final String? value;
  final String screen;

  const _MenuItem({
    required this.label,
    this.value,
    required this.screen,
  });
}