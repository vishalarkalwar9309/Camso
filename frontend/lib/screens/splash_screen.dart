import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // ==============================================================
    // PULSE ANIMATION
    // ==============================================================

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // ==============================================================
    // NAVIGATE TO ONBOARDING
    // ==============================================================

    Timer(
      const Duration(milliseconds: 2600),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const OnboardingScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================================
        // BACKGROUND GRADIENT
        // ==========================================================

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF162B6E),
              Color(0xFF203F99),
              Color(0xFF2D52C4),
            ],
            stops: [
              0.0,
              0.55,
              1.0,
            ],
          ),
        ),

        child: Stack(
          children: [

            // ======================================================
            // BACKGROUND GEOMETRIC PATTERN
            // ======================================================

            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CirclePatternPainter(),
                ),
              ),
            ),

            // ======================================================
            // ORANGE TOP ACCENT
            // ======================================================

            Positioned(
              top: 0,
              left: 0,
              right: 0,

              child: Container(
                height: 4,
                color: AppColors.orange,
              ),
            ),

            // ======================================================
            // LOGO AREA
            // ======================================================

            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,

                builder: (
                  context,
                  child,
                ) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    // ------------------------------------------------
                    // TIRE ICON
                    // ------------------------------------------------

                    Container(
                      width: 96,
                      height: 96,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        color:
                            Colors.white
                                .withValues(
                          alpha: 0.08,
                        ),

                        border:
                            Border.all(
                          color:
                              Colors.white
                                  .withValues(
                            alpha: 0.30,
                          ),
                          width: 6,
                        ),
                      ),

                      child: Center(
                        child: Container(
                          width: 56,
                          height: 56,

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,

                            border:
                                Border.all(
                              color:
                                  AppColors
                                      .orange,
                              width: 4,
                            ),
                          ),

                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,

                              decoration:
                                  const BoxDecoration(
                                color:
                                    AppColors
                                        .orange,
                                shape:
                                    BoxShape
                                        .circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ------------------------------------------------
                    // CAMSO
                    // ------------------------------------------------

                    Text(
                      'CAMSO',

                      style:
                          AppTypography
                              .heading(
                        42,
                        color:
                            Colors.white,
                        weight:
                            FontWeight.w800,
                      ).copyWith(
                        letterSpacing: 6.3,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    // ------------------------------------------------
                    // BY CEAT
                    // ------------------------------------------------

                    Text(
                      'BY CEAT',

                      style:
                          AppTypography.body(
                        12,
                        color:
                            Colors.white
                                .withValues(
                          alpha: 0.60,
                        ),
                        weight:
                            FontWeight.w500,
                      ).copyWith(
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // ------------------------------------------------
                    // COMPACT CONSTRUCTION
                    // ------------------------------------------------

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white
                                .withValues(
                          alpha: 0.06,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),

                        border:
                            Border.all(
                          color:
                              Colors.white
                                  .withValues(
                            alpha: 0.20,
                          ),
                        ),
                      ),

                      child: Text(
                        'COMPACT CONSTRUCTION',

                        style:
                            AppTypography.body(
                          12,
                          color:
                              Colors.white,
                          weight:
                              FontWeight.w500,
                        ).copyWith(
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ======================================================
            // LOADING BAR
            // ======================================================

            Positioned(
              left: 48,
              right: 48,
              bottom: 64,

              child: Column(
                children: [

                  // Track
                  Container(
                    height: 2,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white
                              .withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),

                    child:
                        TweenAnimationBuilder<
                            double>(
                      tween: Tween(
                        begin: 0,
                        end: 1,
                      ),

                      duration:
                          const Duration(
                        milliseconds: 2400,
                      ),

                      curve:
                          Curves.easeInOut,

                      builder: (
                        context,
                        value,
                        child,
                      ) {
                        return FractionallySizedBox(
                          alignment:
                              Alignment
                                  .centerLeft,

                          widthFactor:
                              value,

                          child:
                              Container(
                            height: 2,

                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors
                                      .orange,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Loading…',

                    textAlign:
                        TextAlign.center,

                    style:
                        AppTypography.body(
                      11,
                      color:
                          Colors.white
                              .withValues(
                        alpha: 0.40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // BOTTOM WORDMARK
            // ======================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 22,

              child: Text(
                'A CEAT Limited Company',

                textAlign:
                    TextAlign.center,

                style:
                    AppTypography.body(
                  10,
                  color:
                      Colors.white
                          .withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BACKGROUND CIRCLE PATTERN
// ==================================================================

class _CirclePatternPainter
    extends CustomPainter {

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(
        alpha: 0.10,
      );

    for (int i = 0; i < 8; i++) {
      final diameter =
          80.0 + (i * 55.0);

      canvas.drawCircle(
        center,
        diameter / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}