import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/document_card.dart';
import '../models/app_role.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'contact_support_screen.dart';
import 'dealer_support_screen.dart';
import 'distributor_support_screen.dart';
import 'employee_portal_screen.dart';
import 'faq_screen.dart';
import 'oem_portal_screen.dart';
import 'testimonials_screen.dart';
import 'voc_feedback_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController searchController = TextEditingController();

  String category = 'All';
  String query = '';

  final List<String> categoryKeys = [
    'All',
    'Brochures',
    'Manuals',
    'Maintenance',
    'Technical',
    'Warranty',
  ];

  // Quick navigation items
  final List<_SupportNavItem> supportNav = const [
    _SupportNavItem(
      label: 'FAQ',
      icon: '❓',
      screen: 'faq',
      color: Color(0xFF203F99),
    ),
    _SupportNavItem(
      label: 'Dealer Locator',
      icon: '🏪',
      screen: 'dealer-support',
      color: Color(0xFF2D52C4),
    ),
    _SupportNavItem(
      label: 'Distributor',
      icon: '🏭',
      screen: 'distributor-support',
      color: Color(0xFF162B6E),
    ),
    _SupportNavItem(
      label: 'Employee Portal',
      icon: '💼',
      screen: 'employee-portal',
      color: Color(0xFF203F99),
    ),
    _SupportNavItem(
      label: 'OEM Partner',
      icon: '🚜',
      screen: 'oem-portal',
      color: Color(0xFFF5822D),
    ),
    _SupportNavItem(
      label: 'Contact',
      icon: '📞',
      screen: 'contact-support',
      color: Color(0xFFF5822D),
    ),
    _SupportNavItem(
      label: 'Testimonials',
      icon: '⭐',
      screen: 'testimonials',
      color: Color(0xFF333333),
    ),
    _SupportNavItem(
      label: 'Feedback',
      icon: '💬',
      screen: 'voc-feedback',
      color: Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateTo(String screen) {
    Widget? destination;

    switch (screen) {
      case 'faq':
        destination = const FAQScreen();
        break;
      case 'dealer-support':
        destination = const DealerSupportScreen();
        break;
      case 'distributor-support':
        destination = const DistributorSupportScreen();
        break;
      case 'employee-portal':
        destination = const EmployeePortalScreen();
        break;
      case 'oem-portal':
        destination = const OemPortalScreen();
        break;
      case 'contact-support':
        destination = const ContactSupportScreen();
        break;
      case 'testimonials':
        destination = const TestimonialsScreen();
        break;
      case 'voc-feedback':
        destination = const VOCFeedbackScreen();
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final docs = appState.getVisibleDocuments(category: category, query: query);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: AppColors.blue,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                    if (Navigator.of(context).canPop()) ...[
                      IconButton(
                        tooltip: 'Back',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        'SUPPORT & RESOURCES',
                        style: AppTypography.heading(24,
                                color: Colors.white, weight: FontWeight.w800)
                            .copyWith(letterSpacing: 1.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                  // Search input
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) => setState(() => query = value),
                            style: AppTypography.body(13, color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search documents, guides, manuals…',
                              hintStyle: AppTypography.body(13,
                                  color: Colors.white.withValues(alpha: 0.58)),
                            ),
                          ),
                        ),
                        if (query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              searchController.clear();
                              setState(() => query = '');
                            },
                            child: Icon(
                              Icons.close,
                              size: 17,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 2, color: AppColors.orange),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Navigation Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 580;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: supportNav.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 8 : 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 92,
                          ),
                          itemBuilder: (context, index) =>
                              _quickNavCard(supportNav[index]),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Role-Specific Resource Section
                    _roleResourcesSection(appState),

                    const SizedBox(height: 24),

                    // Document Library Header
                    Row(
                      children: [
                        Text(
                          'DOCUMENT LIBRARY',
                          style: AppTypography.heading(20,
                              color: AppColors.blue, weight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${docs.length} files',
                            style: AppTypography.body(10,
                                color: AppColors.blue, weight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Category Filter Pills
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryKeys.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = categoryKeys[index];
                          final selected = category == item;

                          return GestureDetector(
                            onTap: () => setState(() => category = item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.blue
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                item,
                                style: AppTypography.body(
                                  11,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF555555),
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Documents List
                    if (docs.isEmpty)
                      _emptyState()
                    else
                      Column(
                        children: docs
                            .map((d) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: DocumentCard(doc: d),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role Specific Resource Cards
  Widget _roleResourcesSection(AppState appState) {
    final role = appState.role;
    final isGuest = role == AppRole.guest;
    final List<_RoleResourceGroup> groups = [];

    // CEAT Employee
    if (role == AppRole.employee || role == AppRole.admin || isGuest) {
      groups.add(const _RoleResourceGroup(
        title: 'Employee Resources',
        subtitle: 'Internal engineering guides, training & escalation directory',
        icon: Icons.badge_outlined,
        screen: 'employee-portal',
        permission: _ResourcePermission.employee,
      ));
    }

    // OEM Partner
    if (role == AppRole.oemPartner || role == AppRole.admin || isGuest) {
      groups.add(const _RoleResourceGroup(
        title: 'OEM Partner Resources',
        subtitle: 'Chassis fitment specs, CAD boundary models & Tier-1 data',
        icon: Icons.precision_manufacturing_outlined,
        screen: 'oem-portal',
        permission: _ResourcePermission.oem,
      ));
    }

    // Authorized Dealer
    if (role == AppRole.dealer || role == AppRole.admin || isGuest) {
      groups.add(const _RoleResourceGroup(
        title: 'Dealer Portal & Locator',
        subtitle: 'Dealer sales guides, margin schedules & warranty claims',
        icon: Icons.storefront_outlined,
        screen: 'dealer-support',
        permission: _ResourcePermission.dealer,
      ));
    }

    // Regional Distributor
    if (role == AppRole.distributor || role == AppRole.admin || isGuest) {
      groups.add(const _RoleResourceGroup(
        title: 'Distributor Network',
        subtitle: 'Regional distribution logistics, inventory & buffer matrix',
        icon: Icons.factory_outlined,
        screen: 'distributor-support',
        permission: _ResourcePermission.distributor,
      ));
    }

    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROLE-SPECIFIC RESOURCES',
          style: AppTypography.heading(18,
                  color: AppColors.blue, weight: FontWeight.w700)
              .copyWith(letterSpacing: 0.4),
        ),
        const SizedBox(height: 10),
        ...groups.map((group) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _roleResourceCard(group, appState),
            )),
      ],
    );
  }

  Widget _roleResourceCard(_RoleResourceGroup group, AppState appState) {
    final allowed = switch (group.permission) {
      _ResourcePermission.employee =>
        appState.permissions.canViewInternalResources,
      _ResourcePermission.oem => appState.permissions.canViewOemResources,
      _ResourcePermission.dealer => appState.permissions.canViewDealerSupport,
      _ResourcePermission.distributor =>
        appState.permissions.canViewDistributorSupport,
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (!allowed &&
              (group.permission == _ResourcePermission.employee ||
                  group.permission == _ResourcePermission.oem)) {
            showDialog<void>(
              context: context,
              builder: (dContext) => AlertDialog(
                title: const Text('Sign in required'),
                content: Text(
                  '${group.title} is reserved for authorized accounts. Sign in to access these resources.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dContext);
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            );
            return;
          }
          _navigateTo(group.screen);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
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
                child: Icon(group.icon, color: AppColors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.title,
                          style: AppTypography.body(13, weight: FontWeight.w700),
                        ),
                        const SizedBox(width: 6),
                        if (!allowed)
                          const Icon(Icons.lock, size: 12, color: AppColors.muted),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      group.subtitle,
                      style: AppTypography.body(11, color: AppColors.muted),
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

  Widget _quickNavCard(_SupportNavItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _navigateTo(item.screen),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    10.5,
                    color: item.color,
                    weight: FontWeight.w600,
                  ).copyWith(height: 1.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF1FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 26,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No documents found',
              style: AppTypography.body(14,
                  color: const Color(0xFF333333), weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ResourcePermission { employee, oem, dealer, distributor }

class _RoleResourceGroup {
  final String title;
  final String subtitle;
  final IconData icon;
  final String screen;
  final _ResourcePermission permission;

  const _RoleResourceGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
    required this.permission,
  });
}

class _SupportNavItem {
  final String label;
  final String icon;
  final String screen;
  final Color color;

  const _SupportNavItem({
    required this.label,
    required this.icon,
    required this.screen,
    required this.color,
  });
}