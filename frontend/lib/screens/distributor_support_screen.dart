import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'contact_page_screen.dart';

typedef DistributorRecord = ({
  String id,
  String type,
  String name,
  String address,
  String region,
  String phone,
  String email,
});

class DistributorSupportScreen extends StatefulWidget {
  const DistributorSupportScreen({super.key});

  static const defaultDistributors = <DistributorRecord>[
    (
      id: 'dist001',
      type: 'REGIONAL DISTRIBUTOR',
      name: 'CEAT Specialty Tires — DACH',
      address: 'Lyoner Straße 16, 60528 Frankfurt, Germany',
      region: 'Germany, Austria, Switzerland',
      phone: '+49 69 9500 1100',
      email: 'dach@ceat.com',
    ),
    (
      id: 'dist002',
      type: 'REGIONAL DISTRIBUTOR',
      name: 'CEAT Construction — Western Europe',
      address: 'Rue de la Paix 22, 75001 Paris, France',
      region: 'France, Belgium, Netherlands',
      phone: '+33 1 45 00 2200',
      email: 'westeurope@ceat.com',
    ),
  ];

  @override
  State<DistributorSupportScreen> createState() => _DistributorSupportScreenState();
}

class _DistributorSupportScreenState extends State<DistributorSupportScreen> {
  List<DistributorRecord> _distributors = List.from(DistributorSupportScreen.defaultDistributors);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDistributors());
  }

  Future<void> _fetchDistributors() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final repo = context.read<AppState>().contentRepository;
      final results = await repo.getDealersLocator(type: 'DISTRIBUTOR');
      if (mounted && results.isNotEmpty) {
        final mapped = results.map<DistributorRecord>((item) {
          final city = item['city']?.toString() ?? '';
          final country = item['country']?.toString() ?? '';
          final regionStr = (city.isNotEmpty && country.isNotEmpty)
              ? '$city, $country'
              : (country.isNotEmpty ? country : 'Regional Territory');
          return (
            id: item['id']?.toString() ?? '',
            type: item['type']?.toString() ?? 'REGIONAL DISTRIBUTOR',
            name: item['name']?.toString() ?? '',
            address: '${item['address'] ?? ''}, $city, ${item['state'] ?? ''} $country'.trim(),
            region: regionStr,
            phone: item['phone']?.toString() ?? '+49 69 9500 1100',
            email: item['email']?.toString() ?? 'distributor@camso.co',
          );
        }).toList();

        setState(() {
          _distributors = mapped;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        title: Text(
          'DISTRIBUTOR NETWORK',
          style: AppTypography.heading(24),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.orange),
            ),

          // ======================================================
          // INTRO
          // ======================================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFC8CEDF),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'AUTHORIZED DISTRIBUTOR NETWORK',
                  style: AppTypography.heading(
                    16,
                    color: AppColors.blue,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'CAMSO by CEAT distributors manage regional supply chains and provide technical support for the dealer network. For product availability and pricing, please contact your regional distributor.',
                  style: AppTypography.body(
                    11,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ======================================================
          // DISTRIBUTOR CARDS
          // ======================================================

          ..._distributors.map(
            (dist) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _distributorCard(
                context,
                dist,
              ),
            ),
          ),

          // ======================================================
          // BECOME A DISTRIBUTOR CTA
          // ======================================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'Become a Distributor',
                  style: AppTypography.body(
                    14,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Interested in distributing CAMSO products in your region? Contact our sales team.',
                  style: AppTypography.body(
                    11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 38,
                  child: ElevatedButton(
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
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Enquire Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ============================================================
  // DISTRIBUTOR CARD
  // ============================================================

  Widget _distributorCard(
    BuildContext context,
    ({
      String id,
      String type,
      String name,
      String address,
      String region,
      String phone,
      String email,
    }) dist,
  ) {
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
        children: [

          // Blue top strip
          Container(
            height: 8,
            color: AppColors.blue,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ------------------------------------------------
                // TYPE + NAME
                // ------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D52C4),
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                  child: Text(
                    dist.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  dist.name,
                  style: AppTypography.body(
                    13,
                    weight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Coverage: ${dist.region}',
                  style: AppTypography.body(
                    10,
                    color: AppColors.blue,
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------------------------------------
                // ADDRESS
                // ------------------------------------------------

                _infoRow(
                  Icons.location_on_outlined,
                  dist.address,
                ),

                const SizedBox(height: 7),

                // ------------------------------------------------
                // PHONE
                // ------------------------------------------------

                _infoRow(
                  Icons.phone_outlined,
                  dist.phone,
                ),

                const SizedBox(height: 7),

                // ------------------------------------------------
                // EMAIL
                // ------------------------------------------------

                _infoRow(
                  Icons.email_outlined,
                  dist.email,
                ),

                const SizedBox(height: 13),

                // ------------------------------------------------
                // CALL + EMAIL
                // ------------------------------------------------

                Row(
                  children: [

                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
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
                          child: const Text(
                            'Call',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                          onPressed: () {},
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
                          child: const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
              10,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}