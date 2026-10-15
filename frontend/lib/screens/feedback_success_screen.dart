import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'home_screen.dart';
import 'products_screen.dart';

class FeedbackSuccessScreen extends StatelessWidget {
  const FeedbackSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final referenceId =
        'VOC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ==================================================
                // SUCCESS ICON
                // ==================================================

                Container(
                  width: 80,
                  height: 80,

                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF10B981),
                    size: 40,
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // ORANGE DIVIDER
                // ==================================================

                Container(
                  width: 64,
                  height: 4,

                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  'FEEDBACK RECEIVED',
                  textAlign: TextAlign.center,

                  style: AppTypography.heading(
                    28,
                    color: AppColors.blue,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  'Thank you for sharing your experience with CAMSO by CEAT.',
                  textAlign: TextAlign.center,

                  style: AppTypography.body(
                    13,
                    color: AppColors.body,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your feedback has been submitted to our product team and will be reviewed within 3–5 business days.',
                  textAlign: TextAlign.center,

                  style: AppTypography.body(
                    13,
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // BUTTONS
                // ==================================================

                Column(
                  children: [

                    // Back to Home
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.blue,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          'BACK TO HOME',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Browse Products
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ProductsScreen(),
                            ),
                            (route) => false,
                          );
                        },

                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFF333333),

                          side: const BorderSide(
                            color: AppColors.border,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          'BROWSE PRODUCTS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // REFERENCE ID
                // ==================================================

                Text(
                  'Reference ID: $referenceId',
                  textAlign: TextAlign.center,

                  style: AppTypography.body(
                    10,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}