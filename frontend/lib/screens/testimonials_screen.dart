import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/bookmark_guard.dart';
import '../models/testimonial.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'testimonial_detail_screen.dart';

class TestimonialsScreen extends StatefulWidget {
  const TestimonialsScreen({
    super.key,
  });

  @override
  State<TestimonialsScreen> createState() =>
      _TestimonialsScreenState();
}

class _TestimonialsScreenState
    extends State<TestimonialsScreen> {
  String filter = 'All';

  final List<String> types = [
    'All',
    'Customer Story',
    'Product Story',
    'Tutorial',
    'Replacement Story',
  ];

  List<Testimonial> testimonialsList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTestimonials();
    });
  }

  Future<void> _loadTestimonials() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final repo = context.read<AppState>().contentRepository;
      final fetched = await repo.getTestimonials(pageSize: 50);
      if (mounted) {
        setState(() {
          testimonialsList = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final filtered = filter == 'All'
        ? testimonialsList
        : testimonialsList
            .where((story) => story.type == filter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [

            // ======================================================
            // APP BAR
            // ======================================================

            Container(
              height: 60,
              color: AppColors.blue,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              alignment: Alignment.centerLeft,

              child: Row(
  children: [
    IconButton(
      tooltip: 'Back',
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.read<AppState>().setTab(3);
        }
      },
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        'TESTIMONIALS',
        style: AppTypography.heading(
          24,
          color: Colors.white,
          weight: FontWeight.w800,
        ).copyWith(
          letterSpacing: 1.2,
        ),
      ),
    ),
  ],
),
            ),

            // ======================================================
            // FILTER TABS
            // ======================================================

            Container(
              height: 52,
              color: AppColors.blue,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),

              child: ListView.separated(
                scrollDirection:
                    Axis.horizontal,

                itemCount: types.length,

                separatorBuilder:
                    (_, __) =>
                        const SizedBox(
                  width: 8,
                ),

                itemBuilder:
                    (context, index) {
                  final type = types[index];
                  final selected =
                      filter == type;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        filter = type;
                      });
                    },

                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),

                      decoration:
                          BoxDecoration(
                        color: selected
                            ? AppColors.orange
                            : Colors.white
                                .withValues(
                                alpha: 0.15,
                              ),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      alignment:
                          Alignment.center,

                      child: Text(
                        type,

                        style:
                            AppTypography.body(
                          11,
                          color:
                              Colors.white,
                          weight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ======================================================
            // ORANGE DIVIDER
            // ======================================================

            Container(
              height: 2,
              color: AppColors.orange,
            ),

            // ======================================================
            // STORIES
            // ======================================================

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: AppColors.textSubtle),
                                const SizedBox(height: 12),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.body(14,
                                      color: AppColors.textSubtle),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadTestimonials,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blue,
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No stories found',
                                style: AppTypography.body(14,
                                    color: AppColors.textSubtle),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final story = filtered[index];
                                final isBookmarked = state.isBookmarked(story.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _testimonialCard(
                                    context,
                                    story,
                                    isBookmarked,
                                    state,
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TESTIMONIAL CARD
  // ==============================================================

  Widget _testimonialCard(
    BuildContext context,
    Testimonial story,
    bool isBookmarked,
    AppState state,
  ) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(16),

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestimonialDetailScreen(
              testimonial: story,
              ),
            ),
          );
        },

        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          width: double.infinity,

          decoration:
              BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(
              16,
            ),

            border: Border.all(
              color: AppColors.border,
            ),
          ),

          clipBehavior:
              Clip.antiAlias,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ==================================================
              // COVER IMAGE
              // ==================================================

              SizedBox(
                height: 192,
                width: double.infinity,

                child: Stack(
                  children: [

                    Positioned.fill(
                      child:
                          Image.network(
                        story.coverImage,

                        fit: BoxFit.cover,

                        errorBuilder:
                            (_, __, ___) {
                          return Container(
                            color:
                                AppColors.navy,
                            child:
                                const Icon(
                              Icons
                                  .construction,
                              size: 65,
                              color:
                                  Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration:
                            const BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin:
                                Alignment
                                    .topCenter,
                            end:
                                Alignment
                                    .bottomCenter,
                            colors: [
                              Colors
                                  .transparent,
                              Color
                                  .fromRGBO(
                                22,
                                43,
                                110,
                                0.8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // TYPE BADGE
                    // ==================================================

                    Positioned(
                      top: 14,
                      left: 14,

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              AppColors.orange,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            5,
                          ),
                        ),

                        child: Text(
                          story.type,

                          style:
                              AppTypography
                                  .body(
                            9,
                            color:
                                Colors.white,
                            weight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // BOOKMARK BUTTON
                    // ==================================================

                    Positioned(
                      top: 12,
                      right: 12,

                      child: GestureDetector(
                        onTap: () {
                          BookmarkGuard.toggle(
                            context,
                            story.id,
                            itemName: 'story',
                          );
                        },

                        child: Container(
                          width: 34,
                          height: 34,

                          decoration:
                              const BoxDecoration(
                            color:
                                Colors.white,
                            shape:
                                BoxShape
                                    .circle,
                          ),

                          child: Icon(
                            isBookmarked
                                ? Icons
                                    .bookmark
                                : Icons
                                    .bookmark_border,

                            size: 16,

                            color:
                                isBookmarked
                                    ? AppColors
                                        .blue
                                    : const Color(
                                        0xFF555555,
                                      ),
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // AUTHOR + RATING
                    // ==================================================

                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,

                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,

                        children: [

                          // Avatar
                          ClipOval(
                            child:
                                Image.network(
                              story.avatar,

                              width: 30,
                              height: 30,

                              fit: BoxFit.cover,

                              errorBuilder:
                                  (_, __,
                                      ___) {
                                return Container(
                                  width: 30,
                                  height: 30,
                                  color:
                                      AppColors
                                          .lightBlue,
                                  child:
                                      const Icon(
                                    Icons
                                        .person,
                                    size: 18,
                                    color:
                                        AppColors
                                            .blue,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  story.company,

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      AppTypography
                                          .body(
                                    10,
                                    color:
                                        Colors
                                            .white,
                                    weight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 1,
                                ),

                                Text(
                                  story.location,

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      AppTypography
                                          .body(
                                    9,
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Rating
                          Row(
                            children:
                                List.generate(
                              5,
                              (index) {
                                return Icon(
                                  Icons.star,
                                  size: 10,
                                  color: index <
                                          story
                                              .rating
                                      ? AppColors
                                          .orange
                                      : Colors
                                          .white
                                          .withValues(
                                          alpha:
                                              0.3,
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // CARD CONTENT
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(
                      story.title,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          AppTypography.body(
                        14,
                        color:
                            const Color(
                          0xFF333333,
                        ),
                        weight:
                            FontWeight.w600,
                      ).copyWith(
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      story.excerpt,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          AppTypography.body(
                        11,
                        color:
                            const Color(
                          0xFF6B7280,
                        ),
                      ).copyWith(
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // TAGS
                    // ==================================================

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,

                      children:
                          story.tags.map<
                              Widget>(
                        (tag) {
                          return Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  AppColors
                                      .lightBlue,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),

                            child: Text(
                              tag,

                              style:
                                  AppTypography
                                      .body(
                                9,
                                color:
                                    AppColors
                                        .blue,
                                weight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}