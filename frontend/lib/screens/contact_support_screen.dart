import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: Text(
          'CONTACT SUPPORT',
          style: AppTypography.heading(24),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ======================================================
          // EMERGENCY SUPPORT
          // ======================================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF0E7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.orange,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  '🚨',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Emergency Support',
                        style: AppTypography.body(
                          13,
                          color: const Color(0xFFD4671A),
                          weight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '24/7 critical issue line: +1 800 265 0999',
                        style: AppTypography.body(
                          10,
                          color: const Color(0xFFD4671A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // TECHNICAL SUPPORT
          // ======================================================

          _supportCard(
            title: 'Technical Support',
            description:
                'Product specifications, installation, compatibility',
            phone: '+1 800 265 0623',
            email: 'techsupport@camso.co',
            hours: 'Mon–Fri 08:00–17:00 EST',
            icon: '🔧',
          ),

          const SizedBox(height: 16),

          // ======================================================
          // DEALER SUPPORT
          // ======================================================

          _supportCard(
            title: 'Dealer Support',
            description:
                'Dealer inquiries, new dealer onboarding',
            phone: '+1 800 265 0624',
            email: 'dealer@camso.co',
            hours: 'Mon–Fri 08:00–17:00 EST',
            icon: '🏪',
          ),

          const SizedBox(height: 16),

          // ======================================================
          // WARRANTY CLAIMS
          // ======================================================

          _supportCard(
            title: 'Warranty Claims',
            description:
                'Warranty inquiries and claim submissions',
            phone: '+1 800 265 0625',
            email: 'warranty@camso.co',
            hours: 'Mon–Fri 09:00–16:00 EST',
            icon: '🛡️',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // SUPPORT CARD
  // ============================================================

  Widget _supportCard({
    required String title,
    required String description,
    required String phone,
    required String email,
    required String hours,
    required String icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ------------------------------------------------------
          // BLUE CARD HEADER
          // ------------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: AppColors.blue,

            child: Row(
              children: [

                Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.heading(16).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // CARD CONTENT
          // ------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  description,
                  style: AppTypography.body(
                    10,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 14),

                // Phone
                _infoRow(
                  Icons.phone_outlined,
                  phone,
                  color: const Color(0xFF333333),
                ),

                const SizedBox(height: 9),

                // Email
                _infoRow(
                  Icons.email_outlined,
                  email,
                  color: const Color(0xFF333333),
                ),

                const SizedBox(height: 9),

                // Hours
                _infoRow(
                  Icons.access_time_outlined,
                  hours,
                  color: AppColors.muted,
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // CALL + EMAIL BUTTONS
                // ------------------------------------------------

                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add url_launcher if actual
                            // phone calling is required.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.blue,
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Call',
                            style: AppTypography.body(
                              11,
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add url_launcher if actual
                            // email opening is required.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.lightBlue,
                            foregroundColor:
                                AppColors.blue,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Email',
                            style: AppTypography.body(
                              11,
                              color: AppColors.blue,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String text, {
    required Color color,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 14,
          color: AppColors.muted,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: AppTypography.body(
              10,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}