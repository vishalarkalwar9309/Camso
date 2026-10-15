import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/bookmark_guard.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../data/mock_data.dart';
import '../components/document_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductRepository? repository;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.repository,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  int selectedTab = 0;
  late Product _currentProduct;
  bool _isRefreshing = false;
  String? _refreshError;

  final List<String> tabs = [
    'Overview',
    'Specs',
    'Dimensions',
    'Documents',
  ];

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _fetchProductDetail();
  }

  ProductRepository get _repo =>
      widget.repository ?? context.read<AppState>().productRepository;

  Future<void> _fetchProductDetail() async {
    final identifier = _currentProduct.id.isNotEmpty
        ? _currentProduct.id
        : _currentProduct.pid;
    if (identifier.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      final updated = await _repo.getProductById(identifier);
      if (!mounted) return;
      if (updated != null) {
        setState(() {
          _currentProduct = updated;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _refreshError = e.toString();
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;
    final state = context.watch<AppState>();

    final isBookmarked =
        state.isBookmarked(product.id);

    return Scaffold(
      backgroundColor: AppColors.bg,

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            // ======================================================
            // HERO HEADER
            // ======================================================

            SizedBox(
              height: 248,
              child: Stack(
                children: [
                  // ------------------------------------------------
                  // PRODUCT IMAGE
                  // ------------------------------------------------

                  Positioned.fill(
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (_, __, ___) {
                        return Container(
                          color: AppColors.navy,
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.white54,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),

                  // ------------------------------------------------
                  // BLUE DARK OVERLAY
                  // ------------------------------------------------

                  Positioned.fill(
                    child: Container(
                      decoration:
                          const BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(
                              32,
                              63,
                              153,
                              0.55,
                            ),
                            Color.fromRGBO(
                              22,
                              43,
                              110,
                              0.92,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ------------------------------------------------
                  // TOP BUTTONS
                  // ------------------------------------------------

                  Positioned(
                    top: 10,
                    left: 16,
                    right: 16,

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        _circleButton(
                          icon:
                              Icons.chevron_left,
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                        ),

                        if (_isRefreshing)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          )
                        else if (_refreshError != null)
                          GestureDetector(
                            onTap: _fetchProductDetail,
                            child: const Tooltip(
                              message: 'Failed to refresh latest specs. Tap to retry.',
                              child: Icon(
                                Icons.sync_problem,
                                color: Color(0xFFF5822D),
                                size: 22,
                              ),
                            ),
                          ),

                        Row(
                          children: [
                            _circleButton(
                              icon: isBookmarked
                                  ? Icons.bookmark
                                  : Icons
                                      .bookmark_border,
                              onTap: () {
                                BookmarkGuard.toggle(
                                  context,
                                  product.id,
                                  itemName: 'product',
                                );
                              },
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            _circleButton(
                              icon:
                                  Icons.share_outlined,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // PRODUCT INFORMATION
                  // ------------------------------------------------

                  Positioned(
                    left: 5,
                    right: 5,
                    bottom: 26,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        // Category
                        Row(
                          children: [
                            if (product.isNew)
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
                                      AppColors
                                          .orange,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    5,
                                  ),
                                ),
                                child: Text(
                                  'NEW',
                                  style:
                                      AppTypography
                                          .body(
                                    9,
                                    color:
                                        Colors.white,
                                    weight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),

                            if (product.isNew)
                              const SizedBox(
                                width: 8,
                              ),

                            Text(
                              product.categoryName,
                              style:
                                  AppTypography.body(
                                12,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        // Product name
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              AppTypography.heading(
                            24,
                          ).copyWith(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w700,
                            height: 1.05,
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        // PID + rating
                        Row(
                          children: [
                            Text(
                              'PID: ${product.pid}',
                              style:
                                  AppTypography.body(
                                12,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            // Stars
                            Row(
                              children:
                                  List.generate(
                                5,
                                (index) {
                                  final filled =
                                      index <
                                          product
                                              .rating
                                              .round();

                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      right: 2,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      size: 11,
                                      color: filled
                                          ? AppColors
                                              .orange
                                          : Colors
                                              .white
                                              .withValues(
                                              alpha:
                                                  0.3,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(
                              width: 4,
                            ),

                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                              style:
                                  AppTypography.body(
                                12,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.72,
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
            ),

            // ======================================================
            // KEY SPECIFICATIONS STRIP
            // ======================================================

            Container(
              height: 84,
              color: AppColors.blue,

              child: Row(
                children: [
                  _specItem(
                    product.size,
                    'Size',
                    showBorder: true,
                  ),

                  _specItem(
                    product.maxLoad,
                    'Max Load',
                    showBorder: true,
                  ),

                  _specItem(
                    product.maxSpeed,
                    'Max Speed',
                    showBorder: false,
                  ),
                ],
              ),
            ),

            // ======================================================
            // ORANGE LINE
            // ======================================================

            Container(
              height: 2,
              color: AppColors.orange,
            ),

            // ======================================================
            // TABS
            // ======================================================

            Container(
              height: 60,
              color: Colors.white,

              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) {
                    final selected =
                        selectedTab == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab =
                                index;
                          });
                        },

                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                tabs[index],
                                style:
                                    AppTypography
                                        .body(
                                  13,
                                  color: selected
                                      ? AppColors
                                          .blue
                                      : AppColors
                                          .muted,
                                  weight: selected
                                      ? FontWeight
                                          .w600
                                      : FontWeight
                                          .w500,
                                ),
                              ),
                            ),

                            if (selected)
                              Positioned(
                                bottom: 0,
                                left: 12,
                                right: 12,

                                child:
                                    Container(
                                  height: 3,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        AppColors
                                            .blue,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ======================================================
            // TAB CONTENT
            // ======================================================

            Expanded(
              child: Container(
                color: AppColors.bg,

                child: SingleChildScrollView(
                  physics:
                      const ClampingScrollPhysics(),

                  padding:
                      const EdgeInsets.fromLTRB(
                    5,
                    28,
                    5,
                    30,
                  ),

                  child:
                      _buildTabContent(product),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // CIRCLE BUTTON
  // ==============================================================

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.35,
      ),
      shape: const CircleBorder(),

      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,

        child: SizedBox(
          width: 54,
          height: 54,

          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SPEC ITEM
  // ==============================================================

  Widget _specItem(
    String value,
    String label, {
    required bool showBorder,
  }) {
    return Expanded(
      child: Container(
        height: double.infinity,

        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  right: BorderSide(
                    color: Colors.white
                        .withValues(
                      alpha: 0.16,
                    ),
                  ),
                )
              : null,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Text(
              value,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style:
                  AppTypography.body(
                15,
                color: Colors.white,
                weight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              label,

              style:
                  AppTypography.body(
                10,
                color: Colors.white
                    .withValues(
                  alpha: 0.58,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TAB CONTENT
  // ==============================================================

  Widget _buildTabContent(
    Product product,
  ) {
    switch (selectedTab) {
      case 0:
        return _overviewTab(product);

      case 1:
        return _specificationsTab(product);

      case 2:
        return _dimensionsTab(product);

      case 3:
        return _documentsTab();

      default:
        return _overviewTab(product);
    }
  }

  // ==============================================================
  // OVERVIEW
  // ==============================================================

  Widget _overviewTab(
    Product product,
  ) {
    return Column(
      children: [
        // ----------------------------------------------------------
        // DESCRIPTION
        // ----------------------------------------------------------

        _whiteCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _sectionHeading(
                'DESCRIPTION',
              ),

              const SizedBox(
                height: 18,
              ),

              Text(
                product.description,

                style:
                    AppTypography.body(
                  16,
                  color:
                      const Color(
                    0xFF555555,
                  ),
                ).copyWith(
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        // ----------------------------------------------------------
        // KEY FEATURES
        // ----------------------------------------------------------

        _whiteCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _sectionHeading(
                'KEY FEATURES',
              ),

              const SizedBox(
                height: 20,
              ),

              Column(
                children:
                    product.features
                        .map(
                          (feature) =>
                              _featureBullet(
                            feature,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        // ----------------------------------------------------------
        // APPLICATIONS
        // ----------------------------------------------------------

        _whiteCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _sectionHeading(
                'APPLICATIONS',
              ),

              const SizedBox(
                height: 18,
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: product
                    .applications
                    .map(
                      (application) =>
                          Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 8,
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
                          application,
                          style:
                              AppTypography
                                  .body(
                            11,
                            color:
                                AppColors
                                    .blue,
                            weight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        // ----------------------------------------------------------
        // COMPATIBLE EQUIPMENT
        // ----------------------------------------------------------

        _whiteCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _sectionHeading(
                'COMPATIBLE EQUIPMENT',
              ),

              const SizedBox(
                height: 18,
              ),

              Column(
                children: product
                    .compatibleEquipment
                    .map(
                      (equipment) =>
                          Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .chevron_right,
                              size: 18,
                              color:
                                  AppColors
                                      .muted,
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Text(
                              equipment,
                              style:
                                  AppTypography
                                      .body(
                                14,
                                color:
                                    const Color(
                                  0xFF555555,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // SPECIFICATIONS
  // ==============================================================

  Widget _specificationsTab(
    Product product,
  ) {
    final entries =
        product.specifications.entries
            .toList();

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.format_list_bulleted,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              'No Specifications Available',
              style: AppTypography.heading(16).copyWith(
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Detailed specifications for this product will be published soon.',
              textAlign: TextAlign.center,
              style: AppTypography.body(12, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          clipBehavior:
              Clip.antiAlias,

          child: Column(
            children: List.generate(
              entries.length,
              (index) {
                final entry =
                    entries[index];

                return Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),

                  color: index.isEven
                      ? Colors.white
                      : const Color(
                          0xFFF9FAFB,
                        ),

                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,

                          style:
                              AppTypography
                                  .body(
                            13,
                            color:
                                const Color(
                              0xFF6B7280,
                            ),
                          ),
                        ),
                      ),

                      Text(
                        entry.value,

                        style:
                            AppTypography
                                .body(
                          13,
                          color:
                              const Color(
                            0xFF333333,
                          ),
                          weight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        Container(
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
                  const Color(
                0xFFC8CEDF,
              ),
            ),
          ),

          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color:
                    AppColors.blue,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  'Specifications shown are representative values. Actual values may vary slightly by production batch. Refer to product label for exact figures.',

                  style:
                      AppTypography
                          .body(
                    11,
                    color:
                        AppColors.blue,
                  ).copyWith(
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DIMENSIONS
  // ==============================================================

  Widget _dimensionsTab(
    Product product,
  ) {
    return Column(
      children: [
        _whiteCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _sectionHeading(
                'DIMENSIONAL DATA',
              ),

              const SizedBox(
                height: 18,
              ),

              Container(
                height: 180,
                width: double.infinity,

                decoration:
                    BoxDecoration(
                  color:
                      AppColors.bg,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Center(
                  child: SizedBox(
                    width: 135,
                    height: 135,

                    child: Stack(
                      alignment:
                          Alignment.center,

                      children: [
                        Container(
                          width: 130,
                          height: 130,

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape
                                    .circle,
                            border:
                                Border.all(
                              color:
                                  AppColors
                                      .blue,
                              width: 8,
                            ),
                          ),
                        ),

                        Container(
                          width: 48,
                          height: 48,

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape
                                    .circle,
                            border:
                                Border.all(
                              color:
                                  AppColors
                                      .orange,
                              width: 4,
                            ),
                          ),
                        ),

                        Container(
                          height: 1,
                          width: 130,
                          color:
                              AppColors
                                  .blue
                                  .withValues(
                            alpha: 0.25,
                          ),
                        ),

                        Container(
                          height: 130,
                          width: 1,
                          color:
                              AppColors
                                  .blue
                                  .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        _dimensionTable(product),
      ],
    );
  }

  Widget _dimensionTable(
    Product product,
  ) {
    final rows = [
      [
        'Ply Rating',
        product.plyRating,
      ],
      [
        'Tread Depth',
        product.treadDepth,
      ],
      [
        'Load Index',
        product.loadIndex,
      ],
      [
        'Max Load',
        product.maxLoad,
      ],
      [
        'Max Speed',
        product.maxSpeed,
      ],
    ];

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      clipBehavior:
          Clip.antiAlias,

      child: Column(
        children: List.generate(
          rows.length,
          (index) {
            return Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 18,
                vertical: 16,
              ),

              color: index.isEven
                  ? Colors.white
                  : const Color(
                      0xFFF9FAFB,
                    ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[index][0],
                      style:
                          AppTypography
                              .body(
                        13,
                        color:
                            const Color(
                          0xFF6B7280,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    rows[index][1],
                    style:
                        AppTypography
                            .body(
                      13,
                      color:
                          const Color(
                        0xFF333333,
                      ),
                      weight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==============================================================
  // DOCUMENTS
  // ==============================================================

  Widget _documentsTab() {
  final product = widget.product;

  final productDocuments = documents.where((document) {
    return document.productId == product.id;
  }).toList();

  if (productDocuments.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              'No documents available',
              style: AppTypography.body(
                14,
                color: const Color(0xFF333333),
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are currently no documents associated '
              'with this product.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                12,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    itemCount: productDocuments.length,
    separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
    itemBuilder: (context, index) {
      return DocumentCard(
        doc: productDocuments[index],
      );
    },
  );
}

  // ==============================================================
  // WHITE CARD
  // ==============================================================

  Widget _whiteCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(22),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color: AppColors.border,
        ),
      ),

      child: child,
    );
  }

  // ==============================================================
  // SECTION HEADING
  // ==============================================================

  Widget _sectionHeading(
    String title,
  ) {
    return Text(
      title,

      style:
          AppTypography.heading(
        18,
      ).copyWith(
        color: AppColors.blue,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // ==============================================================
  // FEATURE BULLET
  // ==============================================================

  Widget _featureBullet(
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 7,
            height: 7,

            margin:
                const EdgeInsets.only(
              top: 7,
            ),

            decoration:
                const BoxDecoration(
              color:
                  AppColors.orange,
              shape:
                  BoxShape.circle,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Text(
              text,

              style:
                  AppTypography.body(
                15,
                color:
                    const Color(
                  0xFF333333,
                ),
              ).copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}