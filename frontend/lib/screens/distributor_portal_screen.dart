import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_role.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'distributor_support_screen.dart';
import 'support_screen.dart';

/// Regional Distributor Portal Screen.
///
/// Requirement 2 & 3: Distributor persona access — Supply chain allocation,
/// regional quotas, credit line management, and organization context from /api/v1/business/distributor/portal.
class DistributorPortalScreen extends StatefulWidget {
  const DistributorPortalScreen({super.key});

  @override
  State<DistributorPortalScreen> createState() => _DistributorPortalScreenState();
}

class _DistributorPortalScreenState extends State<DistributorPortalScreen> {
  Map<String, dynamic>? _portalData;
  Map<String, dynamic>? _organization;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = context.watch<AppState>().role;
    final isAuthorized = role == AppRole.distributor || role == AppRole.admin;
    if (isAuthorized && !_hasLoaded && !_isLoading) {
      _hasLoaded = true;
      _loadDistributorData();
    }
  }

  Future<void> _loadDistributorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<AppState>().contentRepository;
      final portal = await repo.getDistributorPortal();
      Map<String, dynamic>? org;
      try {
        org = await repo.getBusinessOrganization();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _portalData = portal;
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
    final isAuthorized = state.role == AppRole.distributor || state.role == AppRole.admin;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'DISTRIBUTOR PORTAL',
          style: AppTypography.heading(20, color: Colors.white),
        ),
      ),
      body: !isAuthorized
          ? _buildUnauthorizedView(context)
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                )
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.textSubtle),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(14, color: AppColors.textSubtle),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDistributorData,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
              child: const Icon(Icons.lock_outline, size: 44, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 18),
            Text(
              'Distributor Authorization Required',
              style: AppTypography.heading(18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This portal requires an approved Regional Distributor account. Switch role or sign in with your distributor credentials.',
              style: AppTypography.body(13, color: AppColors.textSubtle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              child: const Text('Sign in as Distributor', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizedContent(BuildContext context, AppState state) {
    final orgName = _organization?['name']?.toString() ?? state.organizationName ?? 'Regional Distributor';
    final orgCode = _organization?['code']?.toString() ?? 'DISTRIBUTOR';
    final orgStatus = _organization?['status']?.toString() ?? 'APPROVED';
    final orgCity = _organization?['city']?.toString() ?? '';
    final orgCountry = _organization?['country']?.toString() ?? '';
    final locationText = [orgCity, orgCountry].where((s) => s.isNotEmpty).join(', ');

    final features = (_portalData?['authorized_features'] as List?)
            ?.map((e) => e.toString().replaceAll('_', ' ').toUpperCase())
            .toList() ??
        ['DEALER NETWORK ALLOCATION', 'BULK INVENTORY DISPATCH', 'REGIONAL QUOTAS', 'CREDIT LINE MANAGEMENT'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Organization Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.factory_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orgName,
                          style: AppTypography.heading(18, color: Colors.white, weight: FontWeight.w700),
                        ),
                        if (locationText.isNotEmpty)
                          Text(
                            locationText,
                            style: AppTypography.body(12, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      orgStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Code: $orgCode', style: AppTypography.body(11, color: Colors.white.withValues(alpha: 0.9))),
                  Text('Scope: Regional Hub', style: AppTypography.body(11, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Authorized Capabilities
        Text('REGIONAL DISTRIBUTOR CAPABILITIES', style: AppTypography.heading(14, color: AppColors.navy)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: features
                .map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: AppTypography.body(12, weight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 18),

        // Quick Operations
        Text('DISTRIBUTOR OPERATIONS', style: AppTypography.heading(14, color: AppColors.navy)),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _actionTile(
                icon: Icons.hub_outlined,
                title: 'Regional Network',
                subtitle: 'Manage regional hubs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DistributorSupportScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionTile(
                icon: Icons.menu_book_outlined,
                title: 'Commercial Docs',
                subtitle: 'Pricing & distribution specs',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.blue, size: 26),
            const SizedBox(height: 8),
            Text(title, style: AppTypography.heading(13, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.body(10, color: AppColors.textSubtle)),
          ],
        ),
      ),
    );
  }
}
