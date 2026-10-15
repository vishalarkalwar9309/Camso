import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'document_detail_screen.dart';

/// OEM Partner Portal Screen.
///
/// Requirement 3: OEM Partner access — General product experience plus OEM-specific documents and resources.
class OemPortalScreen extends StatefulWidget {
  const OemPortalScreen({super.key});

  @override
  State<OemPortalScreen> createState() => _OemPortalScreenState();
}

class _OemPortalScreenState extends State<OemPortalScreen> {
  List<Document> _oemDocs = [];
  Map<String, dynamic>? _organization;
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isAuthorized = context.watch<AppState>().permissions.canViewOemResources;
    if (isAuthorized && !_hasLoaded && !_isLoading) {
      _hasLoaded = true;
      _loadOemData();
    }
  }

  Future<void> _loadOemData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<AppState>().contentRepository;
      final docs = await repo.getOemDocuments();
      Map<String, dynamic>? org;
      try {
        org = await repo.getBusinessOrganization();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _oemDocs = docs;
          _organization = org;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isAuthorized = state.permissions.canViewOemResources;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'OEM PARTNER PORTAL',
          style: AppTypography.heading(20, color: Colors.white),
        ),
      ),
      body: !isAuthorized
          ? _buildUnauthorizedView(context)
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.orange),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.textSubtle),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(14,
                                  color: AppColors.textSubtle),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOemData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                              ),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
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
              'OEM Partner Access Required',
              style: AppTypography.heading(18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This portal provides engineering drawings, 3D CAD models, hub clearance specs, and Tier-1 quality data for authorized OEM machinery partners.',
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
              child: const Text('Sign in as OEM Partner'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedContent(BuildContext context, AppState state) {
    final docsToDisplay = _oemDocs.isNotEmpty
        ? _oemDocs
        : state.documentItems
            .where((d) => d.accessLevel.isAuthorized(state.role) && !d.isPublic)
            .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // OEM Account Header
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
                      'TIER-1 OEM PROGRAM',
                      style: AppTypography.body(10, color: Colors.white, weight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.precision_manufacturing_outlined,
                      color: Colors.white, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Partner: ${state.userDisplayName}',
                style: AppTypography.heading(20, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                _organization?['name']?.toString() ??
                    state.organizationName ??
                    'Caterpillar Global OEM Division',
                style: AppTypography.body(11, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _sectionTitle('OEM TECHNICAL & CAD DOCUMENTATION'),
        const SizedBox(height: 10),

        ...docsToDisplay.map((doc) => _resourceCard(
              context: context,
              icon: Icons.architecture_outlined,
              title: doc.title,
              subtitle: '${doc.type} · ${doc.fileSize} · v${doc.version}',
              badgeText: 'OEM Restricted',
              badgeColor: const Color(0xFF203F99),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailScreen(
                      documentId: doc.id,
                      title: doc.title,
                    ),
                  ),
                );
              },
            )),

        const SizedBox(height: 20),

        _sectionTitle('OEM APPLICATION ENGINEERING TOOLS'),
        const SizedBox(height: 10),

        _resourceCard(
          context: context,
          icon: Icons.view_in_ar_outlined,
          title: '3D CAD Repository (STEP & IGES)',
          subtitle: 'Direct download library for undercarriage envelope CAD boundaries',
          badgeText: 'CAD Library',
          badgeColor: const Color(0xFF10B981),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('CAD boundary model downloads available via secure OEM token.'),
              ),
            );
          },
        ),

        _resourceCard(
          context: context,
          icon: Icons.verified_outlined,
          title: 'Tier-1 Manufacturing Quality Compliance',
          subtitle: 'ISO 9001 / IATF 16949 audit reports and production certificates',
          badgeText: 'Quality / Audit',
          badgeColor: AppColors.orange,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tier-1 compliance certificates loaded.')),
            );
          },
        ),

        _resourceCard(
          context: context,
          icon: Icons.phone_in_talk_outlined,
          title: 'OEM Dedicated Application Engineering Hotline',
          subtitle: 'Direct line to OEM integration team for chassis development',
          badgeText: 'Direct Line',
          badgeColor: const Color(0xFF6B7280),
          onTap: () {
            _showOemHotlineModal(context);
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

  void _showOemHotlineModal(BuildContext context) {
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
                'OEM Direct Engineering Contacts',
                style: AppTypography.heading(18, color: AppColors.blue),
              ),
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone_forwarded, color: AppColors.blue),
                title: Text('OEM Integration Desk Europe & Americas'),
                subtitle: Text('+1 800 555 CAMSO (ext. 402) · oem-support@camso.co'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.schedule, color: AppColors.blue),
                title: Text('Support Availability'),
                subtitle: Text('Monday – Friday, 07:00 – 19:00 EST / CET'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
