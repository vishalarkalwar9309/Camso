import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  String? openSection = 'terms';
  String? _backendCopyright;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLegalContent());
  }

  Future<void> _fetchLegalContent() async {
    try {
      final repo = context.read<AppState>().contentRepository;
      final data = await repo.getPublicContent('legal');
      if (mounted && data['content'] is Map) {
        final content = data['content'] as Map;
        setState(() {
          _backendCopyright = content['copyright']?.toString();
        });
      }
    } catch (_) {}
  }

  final sections = const [
    (
      id: 'terms',
      title: 'Terms of Use',
      content: '''
By using the CAMSO by CEAT mobile application, you agree to these Terms of Use. This application is provided for informational purposes to assist CAMSO by CEAT customers, dealers, distributors, and partners in accessing product information and support resources.

1. PERMITTED USE
This app is provided for legitimate business purposes related to CAMSO by CEAT products. Users may browse product information, download support documents, and contact support through the app.

2. INTELLECTUAL PROPERTY
All content within this application, including product images, specifications, documents, and branding, is the intellectual property of CEAT Limited and/or its subsidiaries. Reproduction without written permission is prohibited.

3. ACCURACY OF INFORMATION
Product specifications are provided as general guidance only. Always refer to the physical product label and current technical documentation for definitive specifications.

4. LIMITATION OF LIABILITY
CEAT Limited and CAMSO shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use of this application or its content.
''',
    ),
    (
      id: 'privacy',
      title: 'Privacy Policy',
      content: '''
CEAT Limited ("we", "our", "us") is committed to protecting your privacy. This policy explains how we collect, use, and protect your personal information.

DATA WE COLLECT
We may collect: email address, business type, usage analytics, crash reports (if enabled in settings), and bookmarked content.

HOW WE USE YOUR DATA
Your data is used to: personalize your app experience, provide relevant product updates, respond to support inquiries, and improve app performance.

DATA RETENTION
Account data is retained while your account is active. Analytics data is retained for 24 months. You may request deletion of your data by contacting privacy@ceat.com.

YOUR RIGHTS
Under applicable data protection law, you have the right to access, rectify, or delete your personal data. Contact us at privacy@ceat.com to exercise these rights.
''',
    ),
    (
      id: 'warranty',
      title: 'Warranty Disclaimer',
      content: '''
Product information provided in this application is for reference only. CAMSO by CEAT warranty terms are governed by the written warranty documentation provided with each product at time of purchase.

Warranty coverage is subject to the conditions outlined in the current CAMSO Warranty Policy document available in the Support Library. This application does not constitute a warranty claim or warranty extension.

For warranty claims, contact your authorized CAMSO dealer or distributor with proof of purchase and the failed product for inspection.
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          'LEGAL & PRIVACY',
          style: AppTypography.heading(24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...sections.map(
            (section) {
              final isOpen = openSection == section.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE4E7EF),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              openSection =
                                  isOpen ? null : section.id;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    section.title,
                                    style: AppTypography.body(
                                      13,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isOpen
                                        ? AppColors.blue
                                        : const Color(0xFFF2F4F8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: AnimatedRotation(
                                    turns: isOpen ? 0.5 : 0,
                                    duration: const Duration(
                                      milliseconds: 200,
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: isOpen
                                          ? Colors.white
                                          : const Color(0xFF555555),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (isOpen)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            16,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFF2F4F8),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: section.content
                                .trim()
                                .split('\n\n')
                                .map(
                                  (paragraph) {
                                    final isHeading =
                                        RegExp(
                                          r'^[A-Z\d]',
                                        ).hasMatch(paragraph);

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        paragraph,
                                        style: AppTypography.body(
                                          11,
                                          color: isHeading
                                              ? const Color(0xFF333333)
                                              : const Color(0xFF555555),
                                          weight: isHeading
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ).copyWith(
                                          height: 1.55,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FA),
              border: Border.all(
                color: const Color(0xFFC8CEDF),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_backendCopyright != null) ...[
                  Text(
                    _backendCopyright!,
                    style: AppTypography.body(10, color: AppColors.blue, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                ],
                RichText(
                  text: TextSpan(
                    style: AppTypography.body(
                      10,
                      color: AppColors.blue,
                    ).copyWith(height: 1.5),
                    children: const [
                      TextSpan(
                        text:
                            'Last updated: November 2024 · Version 1.0. '
                            'For questions about these policies, contact ',
                      ),
                      TextSpan(
                        text: 'legal@ceat.com',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}