import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'feedback_success_screen.dart';
import 'login_screen.dart';

class VOCFeedbackScreen extends StatefulWidget {
  const VOCFeedbackScreen({super.key});

  @override
  State<VOCFeedbackScreen> createState() =>
      _VOCFeedbackScreenState();
}

class _VOCFeedbackScreenState
    extends State<VOCFeedbackScreen> {
  String category = '';
  int rating = 0;
  String message = '';
  String error = '';
  bool isSubmitting = false;

  final TextEditingController messageController =
      TextEditingController();

  final List<String> categories = [
    'Product Quality',
    'Service',
    'Pricing',
    'Delivery',
    'Technical Support',
    'Other',
  ];

  final List<String> ratingLabels = [
    '',
    'Very Poor',
    'Poor',
    'Neutral',
    'Good',
    'Excellent',
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ==============================================================
  // SUBMIT
  // ==============================================================

  Future<void> handleSubmit() async {
    if (isSubmitting) return;

    final appState = context.read<AppState>();
    if (!appState.loggedIn) {
      setState(() {
        error = 'You must be signed in to submit feedback.';
      });
      return;
    }

    setState(() {
      error = '';
    });

    if (category.isEmpty) {
      setState(() {
        error =
            'Please select a feedback category.';
      });
      return;
    }

    if (rating == 0) {
      setState(() {
        error =
            'Please provide a rating.';
      });
      return;
    }

    if (message.trim().length < 10) {
      setState(() {
        error =
            'Please write at least 10 characters of feedback.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    // Map UI category to valid backend bucket: PRODUCT | SERVICE | PRICING
    String bucket = 'SERVICE';
    if (category.toLowerCase().contains('product')) {
      bucket = 'PRODUCT';
    } else if (category.toLowerCase().contains('pricing')) {
      bucket = 'PRICING';
    }

    try {
      await appState.contentRepository.submitFeedback(
        bucket: bucket,
        rating: rating,
        comment: message.trim(),
      );

      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FeedbackSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isLoggedIn = appState.loggedIn;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======================================================
            // APP BAR (Full-width blue with back button)
            // ======================================================
            Container(
              width: double.infinity,
              color: AppColors.blue,
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SHARE FEEDBACK',
                          style: AppTypography.heading(
                            22,
                            color: Colors.white,
                            weight: FontWeight.w800,
                          ).copyWith(
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Voice of Customer',
                          style: AppTypography.body(
                            11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // ORANGE DIVIDER
            // ======================================================
            Container(
              width: double.infinity,
              height: 2,
              color: AppColors.orange,
            ),

            // ======================================================
            // CONTENT
            // ======================================================
            if (!isLoggedIn)
              _buildLoginRequired(context)
            else
              Expanded(
                child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ==================================================
                    // INTRO CARD
                    // ==================================================

                    Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.lightBlue,

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),

                      child: Text(
                        'Your feedback helps us improve CAMSO products and services. All responses are reviewed by our product team.',

                        style:
                            AppTypography.body(
                          12,
                          color:
                              AppColors.blue,
                        ).copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // CATEGORY
                    // ==================================================

                    Text(
                      'FEEDBACK CATEGORY *',

                      style:
                          AppTypography.body(
                        11,
                        color:
                            const Color(
                          0xFF6B7280,
                        ),
                        weight:
                            FontWeight.w700,
                      ).copyWith(
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    GridView.builder(
                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          categories.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: 48,
                      ),

                      itemBuilder:
                          (context, index) {
                        final item =
                            categories[index];

                        final selected =
                            category == item;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              category = item;
                              error = '';
                            });
                          },

                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 14,
                            ),

                            alignment:
                                Alignment.centerLeft,

                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? AppColors.blue
                                  : Colors.white,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),

                              border: Border.all(
                                color: selected
                                    ? AppColors.blue
                                    : AppColors
                                        .border,

                                width:
                                    selected
                                        ? 1.5
                                        : 1,
                              ),
                            ),

                            child: Text(
                              item,

                              style:
                                  AppTypography
                                      .body(
                                11,
                                color: selected
                                    ? Colors.white
                                    : const Color(
                                        0xFF333333,
                                      ),
                                weight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    // ==================================================
                    // RATING
                    // ==================================================

                    Text(
                      'OVERALL RATING *',

                      style:
                          AppTypography.body(
                        11,
                        color:
                            const Color(
                          0xFF6B7280,
                        ),
                        weight:
                            FontWeight.w700,
                      ).copyWith(
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Center(
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children:
                                List.generate(
                              5,
                              (index) {
                                final star =
                                    index + 1;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      rating =
                                          star;
                                      error = '';
                                    });
                                  },

                                  child:
                                      Padding(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          6,
                                    ),

                                    child: Icon(
                                      star <=
                                              rating
                                          ? Icons
                                              .star
                                          : Icons
                                              .star_border,

                                      size: 40,

                                      color: star <=
                                              rating
                                          ? AppColors
                                              .orange
                                          : const Color(
                                              0xFFE4E7EF,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          if (rating > 0) ...[
                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              ratingLabels[
                                  rating],

                              style:
                                  AppTypography
                                      .body(
                                13,
                                color:
                                    AppColors
                                        .orange,
                                weight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    // ==================================================
                    // MESSAGE
                    // ==================================================

                    Text(
                      'YOUR FEEDBACK *',

                      style:
                          AppTypography.body(
                        11,
                        color:
                            const Color(
                          0xFF6B7280,
                        ),
                        weight:
                            FontWeight.w700,
                      ).copyWith(
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Container(
                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),

                        border: Border.all(
                          color:
                              AppColors.border,
                        ),
                      ),

                      child: TextField(
                        controller:
                            messageController,

                        maxLines: 5,

                        maxLength: 500,

                        onChanged: (value) {
                          setState(() {
                            message = value;
                            error = '';
                          });
                        },

                        style:
                            AppTypography.body(
                          13,
                          color:
                              const Color(
                            0xFF333333,
                          ),
                        ),

                        decoration:
                            InputDecoration(
                          hintText:
                              'Share your experience, suggestions, or concerns…',

                          hintStyle:
                              AppTypography.body(
                            13,
                            color:
                                AppColors.muted,
                          ),

                          border:
                              InputBorder.none,

                          contentPadding:
                              const EdgeInsets
                                  .all(
                            16,
                          ),

                          counterStyle:
                              AppTypography.body(
                            10,
                            color:
                                AppColors.muted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==================================================
                    // ERROR
                    // ==================================================

                    if (error.isNotEmpty)
                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFEE2E2,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xFFEF4444,
                            ),
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Icon(
                              Icons
                                  .error_outline,
                              size: 17,
                              color:
                                  Color(
                                0xFFEF4444,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                error,

                                style:
                                    AppTypography
                                        .body(
                                  11,
                                  color:
                                      const Color(
                                    0xFFEF4444,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // SUBMIT
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child:
                          ElevatedButton(
                        onPressed: isSubmitting ? null : handleSubmit,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors.blue,

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),

                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'SUBMIT FEEDBACK',

                                style:
                                    AppTypography.body(
                                  13,
                                  color:
                                      Colors.white,
                                  weight:
                                      FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
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

  Widget _buildLoginRequired(BuildContext context) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 34,
                    color: AppColors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign In Required',
                  style: AppTypography.heading(20, weight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Voice of Customer feedback is exclusively available for authenticated customers, dealers, distributors, OEM partners, and employees. Please sign in to submit feedback.',
                  style: AppTypography.body(13, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text(
                      'SIGN IN TO SUBMIT FEEDBACK',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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