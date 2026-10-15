import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Admin Organization Approvals Workflow Screen.
///
/// Requirement 6: Organization approval workflows for authorized admins
/// Backend: GET /api/v1/admin/organizations & PATCH /api/v1/admin/organizations/:id/status
class AdminOrganizationApprovalsScreen extends StatefulWidget {
  const AdminOrganizationApprovalsScreen({super.key});

  @override
  State<AdminOrganizationApprovalsScreen> createState() => _AdminOrganizationApprovalsScreenState();
}

class _AdminOrganizationApprovalsScreenState extends State<AdminOrganizationApprovalsScreen> {
  List<Map<String, dynamic>> _organizations = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrganizations());
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<AppState>().contentRepository;
      final statusParam = _selectedFilter == 'ALL' ? null : _selectedFilter;
      final orgs = await repo.getAdminOrganizations(status: statusParam);
      if (mounted) {
        setState(() {
          _organizations = orgs;
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

  Future<void> _updateStatus(String id, String status) async {
    try {
      final repo = context.read<AppState>().contentRepository;
      await repo.updateOrganizationApproval(id: id, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Organization status updated to $status.'),
            backgroundColor: status == 'APPROVED' ? const Color(0xFF10B981) : const Color(0xFFDC2626),
          ),
        );
        _fetchOrganizations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'ORGANIZATION APPROVALS',
          style: AppTypography.heading(19, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _filterChip('ALL', 'All'),
                const SizedBox(width: 8),
                _filterChip('PENDING', 'Pending'),
                const SizedBox(width: 8),
                _filterChip('APPROVED', 'Approved'),
                const SizedBox(width: 8),
                _filterChip('REJECTED', 'Rejected'),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_errorMessage!, style: AppTypography.body(13, color: AppColors.textSubtle)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchOrganizations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _organizations.isEmpty
                        ? Center(
                            child: Text(
                              'No ${_selectedFilter == 'ALL' ? '' : _selectedFilter.toLowerCase()} organizations found.',
                              style: AppTypography.body(13, color: AppColors.textSubtle),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _organizations.length,
                            itemBuilder: (context, index) {
                              final org = _organizations[index];
                              return _buildOrgCard(org);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = filterKey);
        _fetchOrganizations();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildOrgCard(Map<String, dynamic> org) {
    final id = org['id']?.toString() ?? '';
    final name = org['name']?.toString() ?? 'Organization';
    final type = org['type']?.toString() ?? 'DEALER';
    final status = org['status']?.toString() ?? 'PENDING';
    final city = org['city']?.toString() ?? '';
    final country = org['country']?.toString() ?? '';
    final location = [city, country].where((s) => s.isNotEmpty).join(', ');

    Color statusColor;
    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981);
    } else if (status == 'REJECTED') {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(name, style: AppTypography.heading(15, weight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('📍 $location', style: AppTypography.body(11, color: AppColors.textSubtle)),
              ],
            ],
          ),

          if (status == 'PENDING') ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _updateStatus(id, 'REJECTED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Reject', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _updateStatus(id, 'APPROVED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text('Approve', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
