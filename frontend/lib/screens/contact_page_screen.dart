import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ContactPageScreen extends StatelessWidget {
  const ContactPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: Text(
          'CONTACT',
          style: AppTypography.heading(24),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ======================================================
          // GLOBAL HEADQUARTERS
          // ======================================================

          _headquartersCard(),

          const SizedBox(height: 16),

          // ======================================================
          // EUROPE
          // ======================================================

          _regionalOffice(
            region: 'Europe',
            address:
                'Lyoner Straße 16, 60528 Frankfurt, Germany',
            phone: '+49 69 9500 1100',
            email: 'europe@ceat.com',
          ),

          const SizedBox(height: 16),

          // ======================================================
          // NORTH AMERICA
          // ======================================================

          _regionalOffice(
            region: 'North America',
            address:
                '123 Industrial Blvd, Columbus, OH 43215, USA',
            phone: '+1 614 555 0100',
            email: 'americas@ceat.com',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // GLOBAL HEADQUARTERS CARD
  // ============================================================

  Widget _headquartersCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Blue title bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: AppColors.blue,
            child: Text(
              'GLOBAL HEADQUARTERS',
              style: AppTypography.heading(16).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'CEAT Limited',
                  style: AppTypography.body(
                    13,
                    weight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                _infoRow(
                  Icons.location_on_outlined,
                  'CEAT House, 463 Dr. Annie Besant Rd., '
                      'Worli, Mumbai 400 030, India',
                ),

                const SizedBox(height: 9),

                _infoRow(
                  Icons.phone_outlined,
                  '+91 22 6660 2600',
                ),

                const SizedBox(height: 9),

                _infoRow(
                  Icons.email_outlined,
                  'info@ceat.com',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REGIONAL OFFICE CARD
  // ============================================================

  Widget _regionalOffice({
    required String region,
    required String address,
    required String phone,
    required String email,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Region header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                ),
              ),
            ),
            child: Text(
              region,
              style: AppTypography.body(
                12,
                color: AppColors.blue,
                weight: FontWeight.w600,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                _infoRow(
                  Icons.location_on_outlined,
                  address,
                ),

                const SizedBox(height: 9),

                _infoRow(
                  Icons.phone_outlined,
                  phone,
                ),

                const SizedBox(height: 9),

                _infoRow(
                  Icons.email_outlined,
                  email,
                ),

                const SizedBox(height: 12),

                // Call + Email buttons
                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            // Add url_launcher here if
                            // you want actual phone calling.
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
                            // Add url_launcher here if
                            // you want actual email opening.
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
    String text,
  ) {
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
              11,
              color: AppColors.body,
            ),
          ),
        ),
      ],
    );
  }
}