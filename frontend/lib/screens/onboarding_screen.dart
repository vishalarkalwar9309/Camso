import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import '../app.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  int page = 0;

  final List<(String, String)> data = [
    (
      'Built for the toughest jobs',
      'Find the right tires and tracks for your compact construction equipment.',
    ),
    (
      'Product knowledge at your fingertips',
      'Access product information, documents, technical support and customer stories.',
    ),
    (
      'Stay connected with CAMSO',
      'Get product updates, support resources and dealer information in one place.',
    ),
  ];

  void _openApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = data[page];

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 680;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isCompact) const Spacer(),

                        // ============================================================
                        // IMAGE / HERO PLACEHOLDER
                        // ============================================================

                        Container(
                          height: isCompact ? 180 : 260,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.construction,
                              size: isCompact ? 70 : 90,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: isCompact ? 20 : 36),

                        // ============================================================
                        // TITLE
                        // ============================================================

                        Text(
                          current.$1,
                          style: AppTypography.heading(
                            isCompact ? 26 : 34,
                            color: Colors.white,
                            weight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ============================================================
                        // DESCRIPTION
                        // ============================================================

                        Text(
                          current.$2,
                          style: AppTypography.body(
                            14,
                            color: Colors.white70,
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 20),

                        // ============================================================
                        // PAGE INDICATORS
                        // ============================================================

                        Row(
                          children: [
                            for (
                              int i = 0;
                              i < data.length;
                              i++
                            )
                              Container(
                                width: i == page ? 26 : 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.only(
                                  right: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: i == page
                                      ? AppColors.orange
                                      : Colors.white38,
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ============================================================
                        // NEXT / GET STARTED
                        // ============================================================

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (page <
                                  data.length - 1) {
                                setState(() {
                                  page++;
                                });
                              } else {
                                _openApp();
                              }
                            },
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.orange,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              page == data.length - 1
                                  ? 'GET STARTED'
                                  : 'NEXT',
                              style: AppTypography.body(
                                13,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ============================================================
                        // SKIP
                        // ============================================================

                        if (page <
                            data.length - 1)
                          Center(
                            child: TextButton(
                              onPressed: _openApp,
                              child: Text(
                                'Skip',
                                style: AppTypography.body(
                                  12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 38),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}