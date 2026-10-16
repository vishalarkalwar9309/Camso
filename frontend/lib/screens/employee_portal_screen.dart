import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'document_detail_screen.dart';

/// Employee Portal & Internal Resources Screen.
///
/// Requirement 2: Employee access — General product experience plus internal employee resources.
class EmployeePortalScreen extends StatelessWidget {
  const EmployeePortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isAuthorized = state.permissions.canViewInternalResources;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'EMPLOYEE PORTAL',
          style: AppTypography.heading(20, color: Colors.white),
        ),
      ),
      body: !isAuthorized
          ? _buildUnauthorizedView(context)
          : _buildAuthorizedContent(context, state),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 44,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'CEAT Employee Access Required',
              style: AppTypography.heading(18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This portal contains internal product bulletins, engineering standards, and staff training resources. Please sign in with an authorized employee account.',
              style: AppTypography.body(12, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Sign in as Employee'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedContent(BuildContext context, AppState state) {
    final employeeDocs = state.documentItems
        .where((d) => d.accessLevel.isAuthorized(state.role) && !d.isPublic)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Staff Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(16),
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
                    child: Text(
                      'CEAT INTERNAL',
                      style: AppTypography.body(10, color: Colors.white, weight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome, ${state.userDisplayName}',
                style: AppTypography.heading(20, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                state.organizationName ?? 'CEAT Specialty Tyres Ltd.',
                style: AppTypography.body(11, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section Title: Internal Documents
        _sectionTitle('CONFIDENTIAL EMPLOYEE DOCUMENTS'),
        const SizedBox(height: 10),

        ...employeeDocs.map((doc) => _resourceCard(
              context: context,
              icon: Icons.article_outlined,
              title: doc.title,
              subtitle: '${doc.type} · ${doc.fileSize} · v${doc.version}',
              badgeText: 'Internal Only',
              badgeColor: const Color(0xFF203F99),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailScreen(
                      document: doc,
                      documentId: doc.id,
                      title: doc.title,
                    ),
                  ),
                );
              },
            )),

        const SizedBox(height: 20),

        // Section Title: Training & Field Operations
        _sectionTitle('FIELD OPERATIONS & TRAINING'),
        const SizedBox(height: 10),

        _resourceCard(
          context: context,
          icon: Icons.school_outlined,
          title: 'Product Training Modules 2025',
          subtitle: 'Interactive tire compounding and track tensioning courses',
          badgeText: 'Staff LMS',
          badgeColor: const Color(0xFF10B981),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening CEAT Learning Management System...')),
            );
          },
        ),

        _resourceCard(
          context: context,
          icon: Icons.engineering_outlined,
          title: 'Field Engineering Escalation Directory',
          subtitle: 'Direct contact protocols for technical resolution & warranty escalation',
          badgeText: 'Escalations',
          badgeColor: AppColors.orange,
          onTap: () {
            _showContactsModal(context);
          },
        ),

        _resourceCard(
          context: context,
          icon: Icons.fact_check_outlined,
          title: 'Warranty Inspection Photographic Checklist',
          subtitle: 'Standardized checklist for tire cut & lug separation claims',
          badgeText: 'Quality',
          badgeColor: const Color(0xFF6B7280),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photographic checklist loaded from internal assets.')),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.body(11, color: AppColors.muted, weight: FontWeight.w700)
          .copyWith(letterSpacing: 1.1),
    );
  }

  Widget _resourceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.blue, size: 22),
        ),
        title: Text(
          title,
          style: AppTypography.body(13, weight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.body(11, color: AppColors.muted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }

  void _showContactsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Internal Engineering Contacts',
                style: AppTypography.heading(18, color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: AppColors.blue),
                title: Text('Dr. Ramesh Patel — Chief Tyre Engineer'),
                subtitle: Text('ramesh.patel@ceat.com · +91 22 2563 8000'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: AppColors.blue),
                title: Text('Stefan Meier — Field Application Lead Europe'),
                subtitle: Text('stefan.meier@camso.co · +49 89 9500 2210'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
