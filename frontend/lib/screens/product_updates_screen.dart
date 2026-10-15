import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'product_detail_screen.dart';

class ProductUpdatesScreen extends StatefulWidget {
  const ProductUpdatesScreen({super.key});

  @override
  State<ProductUpdatesScreen> createState() => _ProductUpdatesScreenState();
}

class _ProductUpdatesScreenState extends State<ProductUpdatesScreen> {
  List<Map<String, dynamic>> _updates = List<Map<String, dynamic>>.from(productUpdates);
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUpdates());
  }

  Future<void> _fetchUpdates() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final repo = context.read<AppState>().notificationRepository;
      final results = await repo.getProductUpdates();
      if (mounted && results.isNotEmpty) {
        setState(() {
          _updates = results;
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUpdates = _updates.where((u) {
      final type = (u['type'] ?? '').toString().toLowerCase();
      final tag = (u['tag'] ?? '').toString().toLowerCase();
      return type != 'discontinued' && tag != 'discontinued';
    }).toList();

    final unreadCount =
        activeUpdates.where((u) => u['isRead'] == false).length;

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
          'PRODUCT UPDATES',
          style: AppTypography.heading(
            24,
            color: Colors.white,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(
              left: 20,
              bottom: 10,
            ),
            child: Text(
              '$unreadCount unread',
              style: AppTypography.body(
                11,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.orange),
            ),
          ...activeUpdates.map(
            (update) {
              // ----------------------------------------------------
              // FIND RELATED PRODUCT
              // ----------------------------------------------------

              final productId = update['productId'];

              final relatedProduct = productId != null
                  ? products.cast<dynamic>().firstWhere(
                      (p) => p.id == productId,
                      orElse: () => null,
                    )
                  : null;

              final isRead = update['isRead'] == true;

              final String title =
                  update['title']?.toString() ?? '';

              final String summary =
                  update['summary']?.toString() ?? '';

              final String tag =
                  update['tag']?.toString() ?? '';

              final String tagColor =
                  update['tagColor']?.toString() ?? '#203F99';

              final String date =
                  update['date']?.toString() ?? '';

              final String? image =
                  update['image']?.toString();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),

                child: Opacity(
                  opacity: isRead ? 0.85 : 1.0,

                  child: Material(
                    color: Colors.transparent,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),

                      onTap: relatedProduct != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(
                                    product: relatedProduct,
                                  ),
                                ),
                              );
                            }
                          : null,

                      child: Container(
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(16),

                          border: Border.all(
                            color: isRead
                                ? AppColors.border
                                : const Color(0xFFC8CEDF),
                          ),
                        ),

                        clipBehavior: Clip.antiAlias,

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            // ==================================================
                            // IMAGE
                            // ==================================================

                            if (image != null &&
                                image.isNotEmpty)
                              SizedBox(
                                height: 120,
                                width: double.infinity,

                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.cover,

                                        errorBuilder:
                                            (_, __, ___) {
                                          return Container(
                                            color: AppColors.bg,
                                            child: const Center(
                                              child: Icon(
                                                Icons
                                                    .image_outlined,
                                                color:
                                                    Color(
                                                  0xFF9CA3AF,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // ------------------------------------------------
                                    // IMAGE GRADIENT
                                    // ------------------------------------------------

                                    Positioned.fill(
                                      child: Container(
                                        decoration:
                                            const BoxDecoration(
                                          gradient:
                                              LinearGradient(
                                            begin:
                                                Alignment
                                                    .centerLeft,
                                            end:
                                                Alignment
                                                    .centerRight,
                                            colors: [
                                              Color.fromRGBO(
                                                32,
                                                63,
                                                153,
                                                0.3,
                                              ),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ==================================================
                            // CONTENT
                            // ==================================================

                            Padding(
                              padding:
                                  const EdgeInsets.all(16),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  // ==================================================
                                  // TAG + DATE
                                  // ==================================================

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              _tagColor(
                                            tagColor,
                                          ),

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            4,
                                          ),
                                        ),

                                        child: Text(
                                          tag,
                                          style:
                                              AppTypography
                                                  .body(
                                            10,
                                            color:
                                                Colors.white,
                                            weight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ),

                                      const Spacer(),

                                      Row(
                                        children: [
                                          // ------------------------------------------
                                          // UNREAD DOT
                                          // ------------------------------------------

                                          if (!isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin:
                                                  const EdgeInsets
                                                      .only(
                                                right: 6,
                                              ),

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

                                          // ------------------------------------------
                                          // DATE
                                          // ------------------------------------------

                                          Text(
                                            _formatDate(
                                              date,
                                            ),
                                            style:
                                                AppTypography
                                                    .body(
                                              10,
                                              color:
                                                  AppColors
                                                      .muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 9),

                                  // ==================================================
                                  // TITLE
                                  // ==================================================

                                  Text(
                                    title,

                                    style:
                                        AppTypography.body(
                                      14,
                                      weight:
                                          FontWeight.w600,
                                    ).copyWith(
                                      color:
                                          const Color(
                                        0xFF333333,
                                      ),
                                      height: 1.25,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // ==================================================
                                  // SUMMARY
                                  // ==================================================

                                  Text(
                                    summary,

                                    style:
                                        AppTypography.body(
                                      12,
                                      color:
                                          const Color(
                                        0xFF6B7280,
                                      ),
                                    ).copyWith(
                                      height: 1.45,
                                    ),
                                  ),

                                  // ==================================================
                                  // RELATED PRODUCT
                                  // ==================================================

                                  if (relatedProduct != null) ...[
                                    const SizedBox(height: 9),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color:
                                              AppColors.blue,
                                        ),

                                        const SizedBox(width: 2),

                                        Expanded(
                                          child: Text(
                                            'View ${relatedProduct.name}',

                                            overflow:
                                                TextOverflow
                                                    .ellipsis,

                                            style:
                                                AppTypography
                                                    .body(
                                              12,
                                              color:
                                                  AppColors
                                                      .blue,
                                              weight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TAG COLOR
  // ================================================================

  Color _tagColor(String color) {
    final hex = color.replaceAll('#', '');

    try {
      return Color(
        int.parse(
          'FF$hex',
          radix: 16,
        ),
      );
    } catch (_) {
      return AppColors.blue;
    }
  }

  // ================================================================
  // DATE FORMAT
  // ================================================================

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${parsed.day} ${months[parsed.month - 1]}';
    } catch (_) {
      return date;
    }
  }
}