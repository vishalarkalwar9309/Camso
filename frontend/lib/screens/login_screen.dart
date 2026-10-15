import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_service.dart';
import '../models/app_role.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  AppRole selectedRole = AppRole.dealer;
  bool showPassword = false;
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _applyDemoAccount(AppRole.dealer);
  }

  void _applyDemoAccount(AppRole role) {
    setState(() {
      selectedRole = role;
      error = '';
      if (role == AppRole.guest) {
        emailController.clear();
        passwordController.clear();
      } else {
        final demo = AuthService.demoAccounts.firstWhere(
          (d) => d.role == role,
          orElse: () => AuthService.demoAccounts.first,
        );
        emailController.text = demo.email;
        // Do not pre-populate dummy or fake passwords that fail real backend authentication.
        passwordController.clear();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (emailController.text.trim().isEmpty) {
      setState(() => error = 'Please enter your email address.');
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      setState(() => error = 'Please enter your password.');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final state = context.read<AppState>();
      await state.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole,
      );

      if (!mounted) return;
      setState(() => loading = false);

      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e is AuthException ? e.message : 'Sign-in failed. Please verify credentials.';
      });
    }
  }

  Future<void> _handleQuickDemoLogin(AppRole role) async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final state = context.read<AppState>();
      if (role == AppRole.guest) {
        await state.continueAsGuest();
      } else {
        await state.signInAsDemo(role);
      }

      if (!mounted) return;
      setState(() => loading = false);

      Navigator.pushReplacementNamed(context, '/profile');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Quick login failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Blue Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              color: AppColors.blue,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(context, '/profile');
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ROLE-BASED AUTH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CAMSO',
                    style: AppTypography.heading(28).copyWith(
                      color: Colors.white,
                      letterSpacing: 3.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign in to access role-specific resources',
                    style: AppTypography.body(
                      11,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 2, color: AppColors.orange),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // Demo Role Quick Switcher Bar
                  _label('SELECT USER TYPE (DEMO PRESETS)'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _roleChip(AppRole.guest, '👤 Guest', Icons.person_outline),
                      _roleChip(AppRole.dealer, '🏪 Dealer', Icons.storefront_outlined),
                      _roleChip(AppRole.distributor, '🏭 Distributor', Icons.factory_outlined),
                      _roleChip(AppRole.employee, '💼 Employee', Icons.badge_outlined),
                      _roleChip(AppRole.oemPartner, '🚜 OEM Partner', Icons.precision_manufacturing_outlined),
                      _roleChip(AppRole.admin, '⚙️ Admin', Icons.admin_panel_settings_outlined),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Role description banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFC8CEDF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: AppColors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getRoleDescription(selectedRole),
                            style: AppTypography.body(11,
                                color: const Color(0xFF333333)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (selectedRole != AppRole.guest) ...[
                    _label('EMAIL ADDRESS'),
                    _inputField(
                      controller: emailController,
                      hint: 'user@company.com',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    _label('PASSWORD'),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE4E7EF),
                        ),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTypography.body(
                            13,
                            color: AppColors.muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: AppColors.muted,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() => showPassword = !showPassword);
                            },
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.muted,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: AppTypography.body(
                          13,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Text(
                        'Enter password for ${selectedRole.label}. For local testing without backend credentials, use Fast 1-Click Login below.',
                        style: AppTypography.body(11, color: AppColors.muted),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],

                  if (error.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        border: Border.all(color: const Color(0xFFEF4444)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 16, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: AppTypography.body(11,
                                  color: const Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Login Button
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : (selectedRole == AppRole.guest
                              ? () => _handleQuickDemoLogin(AppRole.guest)
                              : _handleLogin),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              selectedRole == AppRole.guest
                                  ? 'CONTINUE AS GUEST'
                                  : 'SIGN IN AS ${selectedRole.label.toUpperCase()}',
                              style: AppTypography.body(
                                13,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Direct Login Shortcut
                  if (selectedRole != AppRole.guest)
                    OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => _handleQuickDemoLogin(selectedRole),
                      icon: const Icon(Icons.bolt, size: 16, color: AppColors.orange),
                      label: Text(
                        'Fast 1-Click Login as ${selectedRole.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE4E7EF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Continue Without Sign-in
                  if (selectedRole != AppRole.guest)
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            _handleQuickDemoLogin(AppRole.guest),
                        child: Text(
                          'Continue as Guest without signing in',
                          style: AppTypography.body(
                            11,
                            color: AppColors.muted,
                            weight: FontWeight.w600,
                          ),
                        ),
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

  Widget _roleChip(AppRole role, String label, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => _applyDemoAccount(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.blue : const Color(0xFFE4E7EF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTypography.body(
          10,
          color: const Color(0xFF6B7280),
          weight: FontWeight.w700,
        ).copyWith(letterSpacing: 1),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE4E7EF),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.body(13, color: AppColors.muted),
          prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: AppTypography.body(13, color: const Color(0xFF333333)),
      ),
    );
  }

  String _getRoleDescription(AppRole role) {
    switch (role) {
      case AppRole.guest:
        return 'Guest: Browse public catalogue and use pressure & TKPH calculators. Saving results and restricted documents require signing in.';
      case AppRole.dealer:
        return 'Dealer (Alpine Equipment GmbH): Access dealer pricing schedules, commercial margins, warranty claim manuals, and save calculator outputs.';
      case AppRole.distributor:
        return 'Distributor (CEAT DACH): Access regional supply chain allocation, distributor logistics manuals, and dealer network support.';
      case AppRole.employee:
        return 'CEAT Employee (Jean Schmidt): Access internal employee handbook, technical specifications, and field engineering escalation directory.';
      case AppRole.oemPartner:
        return 'OEM Partner (Caterpillar OEM): Access 3D CAD models, chassis fitment tolerances, and Tier-1 quality compliance records.';
      case AppRole.admin:
        return 'Admin (Alex Morgan): Content management access for products, categories, documents, notifications, product updates, and catalogue analytics.';
    }
  }
}