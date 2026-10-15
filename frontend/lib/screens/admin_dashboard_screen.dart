import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/app_role.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'activity_screen.dart';
import 'admin_content_management_screen.dart';
import 'admin_organization_approvals_screen.dart';

class _AdminSection {
  const _AdminSection(
    this.title,
    this.subtitle,
    this.icon,
    this.count,
    this.keyName,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final int? count;
  final String keyName;
}

/// Admin Dashboard Screen.
///
/// Requirement 1: Admin capabilities — Manage products, categories, documents,
/// notifications, and product updates, in addition to viewing analytics.
/// User management is intentionally excluded per scope requirements.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.loggedIn || state.role != AppRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              const Text('Admin access is required.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Sign in as Admin'),
              ),
            ],
          ),
        ),
      );
    }

    final unread = state.notificationItems.where((n) => !n.isRead).length;
    final sections = <_AdminSection>[
      _AdminSection('Products', 'Manage catalogue products & specifications',
          Icons.inventory_2_outlined, state.productItems.length, 'products'),
      _AdminSection('Categories', 'Product hierarchy & filter categories',
          Icons.category_outlined, categories.length, 'categories'),
      _AdminSection('Documents', 'Manage public & restricted document library',
          Icons.description_outlined, state.documentItems.length, 'documents'),
      _AdminSection('Notifications', 'Dispatch broadcast push notifications',
          Icons.notifications_active_outlined, state.notificationItems.length, 'notifications'),
      _AdminSection('Product Updates', 'Publish and manage product updates',
          Icons.campaign_outlined, productUpdates.length, 'updates'),
      const _AdminSection('Organization Approvals', 'Approve/reject pending business registrations',
          Icons.domain_verification_outlined, null, 'organizations'),
      const _AdminSection('Analytics', 'Catalogue usage, feedback & demand metrics',
          Icons.bar_chart_outlined, null, 'analytics'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'ADMIN DASHBOARD',
          style: AppTypography.heading(20, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CMS CONTROL PANEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.admin_panel_settings_outlined,
                        color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Content & Catalogue Management',
                    style: AppTypography.heading(20, color: Colors.white)),
                const SizedBox(height: 6),
                Text(
                  'Manage catalogue items, role-restricted documents, announcements, and review demand analytics.',
                  style: AppTypography.body(11,
                      color: Colors.white.withValues(alpha: .85)),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _summaryPill('${state.productItems.length} products'),
                    _summaryPill('${categories.length} categories'),
                    _summaryPill('${state.documentItems.length} documents'),
                    _summaryPill('$unread unread alerts'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _openSection(context, section),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(section.icon, color: AppColors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(section.title,
                                    style: AppTypography.body(14,
                                        weight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(section.subtitle,
                                    style: AppTypography.body(11,
                                        color: AppColors.muted)),
                              ],
                            ),
                          ),
                          if (section.count != null)
                            Text('${section.count}',
                                style: AppTypography.heading(18,
                                    color: AppColors.blue)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'User management is excluded from client scope per specification.',
              style: AppTypography.body(10, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryPill(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  void _openSection(BuildContext context, _AdminSection section) {
    if (section.keyName == 'organizations') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminOrganizationApprovalsScreen()),
      );
      return;
    }

    if (section.keyName == 'analytics') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ActivityScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminContentManagementScreen(section: section.title),
      ),
    );
  }
}
