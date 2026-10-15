import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/bookmark_guard.dart';
import '../models/testimonial.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'product_detail_screen.dart';

class TestimonialDetailScreen extends StatelessWidget {
  final Testimonial testimonial;

  const TestimonialDetailScreen({
    super.key,
    required this.testimonial,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final relatedProduct = testimonial.productId == null
        ? null
        : state.productItems.cast<Product?>().firstWhere(
            (p) => p?.id == testimonial.productId,
            orElse: () => null,
          );

    final isBookmarked =
        state.isBookmarked(testimonial.id);

    return Scaffold(
      backgroundColor: AppColors.bg,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          testimonial.type.toUpperCase(),
          style: AppTypography.heading(
            22,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              BookmarkGuard.toggle(context, testimonial.id, itemName: 'testimonial');
            },
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: Colors.white,
            ),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [

          // ========================================================
          // COVER IMAGE
          // ========================================================

          SizedBox(
            height: 220,
            width: double.infinity,
            child: Image.network(
              testimonial.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: AppColors.navy,
                  child: const Icon(
                    Icons.construction,
                    size: 70,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ==================================================
                // TYPE
                // ==================================================

                Text(
                  testimonial.type.toUpperCase(),
                  style: AppTypography.body(
                    11,
                    color: AppColors.orange,
                    weight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  testimonial.title,
                  style: AppTypography.heading(30),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // COMPANY
                // ==================================================

                Text(
                  testimonial.company,
                  style: AppTypography.body(
                    13,
                    color: AppColors.blue,
                    weight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  testimonial.location,
                  style: AppTypography.body(
                    12,
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // AUTHOR CARD
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.border,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [

                      ClipOval(
                        child: Image.network(
                          testimonial.avatar,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return Container(
                              width: 48,
                              height: 48,
                              color: AppColors.bg,
                              child: const Icon(
                                Icons.person,
                                color:
                                    AppColors.muted,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              testimonial.contact,
                              style:
                                  AppTypography.body(
                                12,
                                color:
                                    AppColors.text,
                                weight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              testimonial.company,
                              style:
                                  AppTypography.body(
                                11,
                                color:
                                    AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating
                      Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          for (int i = 1; i <= 5; i++)
                            Icon(
                              i <= testimonial.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 15,
                              color:
                                  AppColors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // TAGS
                // ==================================================

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: testimonial.tags.map(
                    (tag) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFEEF1FA),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          tag,
                          style:
                              AppTypography.body(
                            10,
                            color: AppColors.blue,
                            weight:
                                FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STORY CONTENT
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.border,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: testimonial.content
                        .split('\n\n')
                        .map(
                          (paragraph) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Text(
                                paragraph,
                                style:
                                    AppTypography.body(
                                  12,
                                  color:
                                      AppColors.body,
                                ),
                              ),
                            );
                          },
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // DATE
                // ==================================================

                Text(
                  'Published ${testimonial.date}',
                  style: AppTypography.body(
                    11,
                    color: AppColors.muted,
                  ),
                ),

                // ==================================================
                // RELATED PRODUCT
                // ==================================================

                if (relatedProduct != null) ...[
                  const SizedBox(height: 24),

                  Text(
                    'FEATURED PRODUCT',
                    style: AppTypography.body(
                      11,
                      color: AppColors.muted,
                      weight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(
                            product: relatedProduct,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.border,
                        ),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [

                          // Product image
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                            child: Image.network(
                              relatedProduct.image,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) {
                                return Container(
                                  width: 52,
                                  height: 52,
                                  color:
                                      AppColors.bg,
                                  child: const Icon(
                                    Icons
                                        .image_outlined,
                                    color:
                                        AppColors.muted,
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  relatedProduct.name,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      AppTypography.body(
                                    13,
                                    color:
                                        AppColors.text,
                                    weight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  relatedProduct.size,
                                  style:
                                      AppTypography.body(
                                    11,
                                    color:
                                        AppColors.blue,
                                    weight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 15,
                            color:
                                AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}