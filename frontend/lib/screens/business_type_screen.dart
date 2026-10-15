import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../data/mock_data.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class BusinessTypeScreen extends StatefulWidget {
  const BusinessTypeScreen({super.key});

  @override
  State<BusinessTypeScreen> createState() =>
      _BusinessTypeScreenState();
}

class _BusinessTypeScreenState
    extends State<BusinessTypeScreen> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ============================================================
          // BLUE HEADER
          // ============================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              52,
              20,
              20,
            ),
            color: AppColors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT YOUR BUSINESS TYPE',
                  style: AppTypography.heading(25).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'This helps us tailor the app experience to your role.',
                  style: AppTypography.body(
                    11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // ORANGE DIVIDER
          // ============================================================

          Container(
            height: 2,
            color: AppColors.orange,
          ),

          // ============================================================
          // BUSINESS TYPES
          // ============================================================

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...businessTypes.map(
                  (businessType) {
                    final String id =
                        businessType['id'] ?? '';

                    final String name =
                        businessType['name'] ?? '';

                    final String description =
                        businessType['description'] ?? '';

                    final bool isSelected =
                        selected == id;

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: _businessTypeCard(
                        businessType: name,
                        description: description,
                        id: id,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            selected = id;
                          });
                        },
                      ),
                    );
                  },
                ),

                // ======================================================
                // CONTINUE BUTTON
                // ======================================================

                const SizedBox(height: 2),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () {
                            state.setBusinessRole(selected);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      disabledBackgroundColor:
                          AppColors.blue.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue with Selected Persona',
                      style: AppTypography.body(
                        13,
                        color: Colors.white,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                if (selected == 'dealer' || selected == 'distributor' || selected == 'oem') ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRegisterBusinessDialog(context, selected),
                      icon: const Icon(Icons.app_registration, size: 18),
                      label: Text(
                        'Register Business Account (Official)',
                        style: AppTypography.body(
                          12,
                          color: AppColors.blue,
                          weight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        side: const BorderSide(color: AppColors.blue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterBusinessDialog(BuildContext context, String rawRole) {
    final orgType = rawRole == 'oem'
        ? 'OEM_PARTNER'
        : (rawRole == 'distributor' ? 'DISTRIBUTOR' : 'DEALER');

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final countryController = TextEditingController(text: 'Germany');
    final userNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Register Business Account ($orgType)',
            style: AppTypography.heading(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submitted accounts are registered with PENDING status for administrator review.',
                  style: AppTypography.body(11, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization / Company Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Business Address',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: countryController,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),
                Text('Primary Contact & Credentials',
                    style: AppTypography.body(12, weight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Full Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Official Business Email *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (min. 8 characters) *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final orgName = nameController.text.trim();
                      final email = emailController.text.trim();
                      final password = passwordController.text;

                      if (orgName.isEmpty || email.isEmpty || password.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter Company Name, Email, and a password of at least 8 characters.',
                            ),
                            backgroundColor: Color(0xFFDC2626),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        final repo = context.read<AppState>().contentRepository;
                        await repo.registerBusinessOrganization(
                          organization: {
                            'name': orgName,
                            'type': orgType,
                            'address': addressController.text.trim(),
                            'city': cityController.text.trim(),
                            'country': countryController.text.trim(),
                          },
                          user: {
                            'email': email,
                            'password': password,
                            'display_name': userNameController.text.trim().isNotEmpty
                                ? userNameController.text.trim()
                                : orgName,
                          },
                        );

                        if (!dialogCtx.mounted) return;
                        Navigator.pop(dialogCtx);

                        if (!context.mounted) return;
                        showDialog<void>(
                          context: context,
                          builder: (okCtx) => AlertDialog(
                            title: const Text('Registration Submitted'),
                            content: Text(
                              'Thank you for registering "$orgName". Your account status is PENDING administrator review.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(okCtx);
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: const Color(0xFFDC2626),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit Registration'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS TYPE CARD
  // ============================================================

  Widget _businessTypeCard({
    required String businessType,
    required String description,
    required String id,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightBlue
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // ==========================================================
            // ICON
            // ==========================================================

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.blue
                    : AppColors.bg,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Center(
                child: _businessIcon(
                  id,
                  selected,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ==========================================================
            // TEXT
            // ==========================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    businessType,
                    style: AppTypography.body(
                      13,
                      color: selected
                          ? AppColors.blue
                          : const Color(0xFF333333),
                      weight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    description,
                    style: AppTypography.body(
                      10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // CHECKMARK
            // ==========================================================

            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration:
                    const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICONS
  // ============================================================

  Widget _businessIcon(
    String id,
    bool selected,
  ) {
    final color = selected
        ? Colors.white
        : const Color(0xFF555555);

    switch (id) {
      case 'dealer':
        return Icon(
          Icons.storefront_outlined,
          size: 25,
          color: color,
        );

      case 'distributor':
        return Icon(
          Icons.local_shipping_outlined,
          size: 25,
          color: color,
        );

      case 'oem':
        return Icon(
          Icons.settings_outlined,
          size: 25,
          color: color,
        );

      case 'employee':
        return Icon(
          Icons.person_outline,
          size: 25,
          color: color,
        );

      case 'admin':
        return Icon(
          Icons.admin_panel_settings_outlined,
          size: 25,
          color: color,
        );

      default:
        return Icon(
          Icons.help_outline,
          size: 25,
          color: color,
        );
    }
  }
}