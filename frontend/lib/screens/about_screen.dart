import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'contact_page_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _tagline;
  String? _company;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAboutContent());
  }

  Future<void> _fetchAboutContent() async {
    try {
      final repo = context.read<AppState>().contentRepository;
      final data = await repo.getPublicContent('about');
      if (mounted && data['content'] is Map) {
        final content = data['content'] as Map;
        setState(() {
          _tagline = content['tagline']?.toString();
          _company = content['company']?.toString();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ============================================================
            // TOP APP BAR
            // ============================================================

            Container(
              height: 64,
              color: AppColors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'ABOUT CAMSO',
                    style: AppTypography.heading(24).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // ORANGE ACCENT
            // ============================================================

            Container(
              height: 2,
              color: AppColors.orange,
            ),

            // ============================================================
            // CONTENT
            // ============================================================

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // ======================================================
                    // HERO
                    // ======================================================

                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800&h=400&fit=crop&auto=format',
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Container(
                                  color: AppColors.blue,
                                );
                              },
                            ),
                          ),

                          // Dark blue overlay
                          Positioned.fill(
                            child: Container(
                              color: AppColors.blue.withValues(
                                alpha: 0.68,
                              ),
                            ),
                          ),

                          // Hero content
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CAMSO',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.heading(36).copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4.0,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    _company ?? 'by CEAT',
                                    style: AppTypography.body(
                                      12,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      weight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 9),

                                  Container(
                                    width: 48,
                                    height: 2,
                                    color: AppColors.orange,
                                  ),

                                  const SizedBox(height: 9),

                                  Text(
                                    _tagline ?? 'Compact Construction Tires & Tracks',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(
                                      14,
                                      color: Colors.white,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======================================================
                    // MAIN CONTENT
                    // ======================================================

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // ==================================================
                          // OUR MISSION
                          // ==================================================

                          _sectionCard(
                            title: 'OUR MISSION',
                            child: Text(
                              'CAMSO by CEAT is dedicated to engineering '
                              'world-class tires and tracks for compact '
                              'construction equipment. Our products are '
                              'designed to maximize uptime, reduce total '
                              'cost of ownership, and deliver reliable '
                              'performance in the most demanding '
                              'construction environments worldwide.',
                              style: AppTypography.body(
                                13,
                                color: const Color(0xFF555555),
                              ).copyWith(
                                height: 1.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // STATS
                          // ==================================================

                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.45,
                            children: const [
                              _StatCard(
                                value: '30+',
                                label: 'Years of Experience',
                              ),
                              _StatCard(
                                value: '120+',
                                label: 'Countries Served',
                              ),
                              _StatCard(
                                value: '400+',
                                label: 'Products in Range',
                              ),
                              _StatCard(
                                value: '2,000+',
                                label: 'Authorized Dealers',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // PART OF CEAT LIMITED
                          // ==================================================

                          _sectionCard(
                            title: 'PART OF CEAT LIMITED',
                            child: Text(
                              'CAMSO is a brand of CEAT Limited, one of '
                              'India\'s largest tyre manufacturers with a '
                              'global presence. CEAT Limited is part of the '
                              'RPG Group, a diversified conglomerate with '
                              'over 20 companies.',
                              style: AppTypography.body(
                                13,
                                color: const Color(0xFF555555),
                              ).copyWith(
                                height: 1.55,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // CONTACT US
                          // ==================================================

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONTACT US',
                                  style: AppTypography.heading(18).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Global Headquarters: CEAT House, '
                                  '463 Dr. Annie Besant Rd., Worli, '
                                  'Mumbai 400 030, India',
                                  style: AppTypography.body(
                                    11,
                                    color: Colors.white.withValues(
                                      alpha: 0.7,
                                    ),
                                  ).copyWith(
                                    height: 1.45,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ContactPageScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.orange,
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 0,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 11,
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Contact Information',
                                    style: AppTypography.body(
                                      12,
                                      color: Colors.white,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
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

  // ================================================================
  // SECTION CARD
  // ================================================================

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.heading(18).copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          child,
        ],
      ),
    );
  }
}

// ==================================================================
// STAT CARD
// ==================================================================

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTypography.heading(28).copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              10,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}