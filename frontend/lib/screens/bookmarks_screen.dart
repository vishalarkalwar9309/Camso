import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../data/mock_data.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/product_card.dart';
import '../components/document_card.dart';
import 'testimonial_detail_screen.dart';
import 'products_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() =>
      _BookmarksScreenState();
}

class _BookmarksScreenState
    extends State<BookmarksScreen> {

  // ============================================================
  // MAIN TAB
  // ============================================================

  int selectedTab = 0;

  // 0 = Products
  // 1 = Documents
  // 2 = Stories

  // ============================================================
  // FILTERS
  // ============================================================

  String productFilter = 'all';
  String documentFilter = 'all';
  String storyFilter = 'all';

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _liveBookmarkedProducts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookmarks();
    });
  }

  Future<void> _loadBookmarks() async {
    final state = context.read<AppState>();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await state.bookmarkRepository.getBookmarkedProducts();
      if (!mounted) return;
      setState(() {
        _liveBookmarkedProducts = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  final List<Map<String, String>> productFilters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'skid-steer', 'label': 'Skid Steer'},
    {'key': 'telehandler', 'label': 'Telehandler'},
    {'key': 'rubber-tracks', 'label': 'Rubber Tracks'},
    {'key': 'steel-tracks', 'label': 'Steel Tracks'},
    {'key': 'backhoe', 'label': 'Backhoe'},
    {'key': 'excavator', 'label': 'Excavator'},
  ];

  final List<Map<String, String>> documentFilters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'brochures', 'label': 'Brochures'},
    {'key': 'manuals', 'label': 'Manuals'},
    {'key': 'maintenance', 'label': 'Maintenance'},
    {'key': 'technical', 'label': 'Technical'},
    {'key': 'warranty', 'label': 'Warranty'},
  ];

  final List<Map<String, String>> storyFilters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'Customer Story', 'label': 'Customer'},
    {'key': 'Product Story', 'label': 'Product'},
    {'key': 'Tutorial', 'label': 'Tutorial'},
    {'key': 'Replacement Story', 'label': 'Replacement'},
  ];

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Use live bookmarked products from API, plus any products matching current IDs
    final bookmarkedProducts = _liveBookmarkedProducts.isNotEmpty
        ? _liveBookmarkedProducts
        : products.where((p) => state.isBookmarked(p.id)).toList();

    final bookmarkedDocs = state.documentItems
        .where((d) => state.isBookmarked(d.id))
        .toList();

    final bookmarkedStories = testimonials
        .where((s) => state.isBookmarked(s.id))
        .toList();

    final filteredProducts = productFilter == 'all'
        ? bookmarkedProducts
        : bookmarkedProducts.where((p) {
            return p.category == productFilter || p.categoryName.toLowerCase().contains(productFilter);
          }).toList();

    final filteredDocs = documentFilter == 'all'
        ? bookmarkedDocs
        : bookmarkedDocs.where((d) {
            return d.category == documentFilter;
          }).toList();

    final filteredStories = storyFilter == 'all'
        ? bookmarkedStories
        : bookmarkedStories.where((s) {
            return s.type == storyFilter;
          }).toList();


    return Scaffold(
      backgroundColor: AppColors.bg,

      // ==========================================================
      // HEADER
      // ==========================================================

      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'BOOKMARKS',
          style: AppTypography.heading(25).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ),

      body: Column(
        children: [

          // ======================================================
          // MAIN TABS
          // ======================================================

          Container(
            height: 52,
            color: Colors.white,
            child: Row(
              children: [
                _mainTab(
                  label: 'Products',
                  count: bookmarkedProducts.length,
                  index: 0,
                ),
                _mainTab(
                  label: 'Documents',
                  count: bookmarkedDocs.length,
                  index: 1,
                ),
                _mainTab(
                  label: 'Stories',
                  count: bookmarkedStories.length,
                  index: 2,
                ),
              ],
            ),
          ),

          // ======================================================
          // FILTER RIBBON
          // ======================================================

          if (selectedTab == 0 &&
              bookmarkedProducts.isNotEmpty)
            _filterRibbon(
              filters: productFilters,
              active: productFilter,
              onChanged: (value) {
                setState(() {
                  productFilter = value;
                });
              },
            ),

          if (selectedTab == 1 &&
              bookmarkedDocs.isNotEmpty)
            _filterRibbon(
              filters: documentFilters,
              active: documentFilter,
              onChanged: (value) {
                setState(() {
                  documentFilter = value;
                });
              },
            ),

          if (selectedTab == 2 &&
              bookmarkedStories.isNotEmpty)
            _filterRibbon(
              filters: storyFilters,
              active: storyFilter,
              onChanged: (value) {
                setState(() {
                  storyFilter = value;
                });
              },
            ),

          // ======================================================
          // CONTENT
          // ======================================================

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.orange),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.textSubtle),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: AppTypography.body(14,
                                    color: AppColors.textSubtle),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadBookmarks,
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
                    : _buildContent(
                        context,
                        bookmarkedProducts,
                        bookmarkedDocs,
                        bookmarkedStories,
                        filteredProducts,
                        filteredDocs,
                        filteredStories,
                      ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN TAB
  // ============================================================

  Widget _mainTab({
    required String label,
    required int count,
    required int index,
  }) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? AppColors.blue
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.body(
                  11,
                  color: selected
                      ? AppColors.blue
                      : AppColors.muted,
                  weight: FontWeight.w600,
                ),
              ),

              if (count > 0) ...[
                const SizedBox(width: 5),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.lightBlue
                        : AppColors.bg,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTypography.body(
                      9,
                      color: selected
                          ? AppColors.blue
                          : AppColors.muted,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER RIBBON
  // ============================================================

  Widget _filterRibbon({
    required List<Map<String, String>> filters,
    required String active,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF2F4F8),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final key = filter['key']!;
          final label = filter['label']!;
          final selected = active == key;

          return Padding(
            padding:
                const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.blue
                      : AppColors.bg,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Text(
                  label,
                  style: AppTypography.body(
                    10,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF555555),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CONTENT SWITCH
  // ============================================================

  Widget _buildContent(
    BuildContext context,
    List bookmarkedProducts,
    List bookmarkedDocs,
    List bookmarkedStories,
    List filteredProducts,
    List filteredDocs,
    List filteredStories,
  ) {
    if (selectedTab == 0) {
      if (bookmarkedProducts.isEmpty) {
        return _emptyState(
          context,
          message: 'No bookmarked products yet',
          subtitle:
              'Save products to find them quickly later.',
        );
      }

      if (filteredProducts.isEmpty) {
        return _noMatch();
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: filteredProducts
            .map(
              (product) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: ProductCard(
                  product: product,
                  compact: true,
                ),
              ),
            )
            .toList(),
      );
    }

    if (selectedTab == 1) {
      if (bookmarkedDocs.isEmpty) {
        return _emptyState(
          context,
          message: 'No bookmarked documents yet',
          subtitle:
              'Save documents to find them quickly later.',
        );
      }

      if (filteredDocs.isEmpty) {
        return _noMatch();
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: filteredDocs
            .map(
              (document) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: DocumentCard(
                  doc: document,
                ),
              ),
            )
            .toList(),
      );
    }

    if (bookmarkedStories.isEmpty) {
      return _emptyState(
        context,
        message: 'No bookmarked stories yet',
        subtitle:
            'Save stories to find them quickly later.',
      );
    }

    if (filteredStories.isEmpty) {
      return _noMatch();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: filteredStories
          .map(
            (story) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: _storyCard(
                context,
                story,
              ),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(
    BuildContext context, {
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 26,
                color: AppColors.blue,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                13,
                color: const Color(0xFF333333),
                weight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                11,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProductsScreen(),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius:
                      BorderRadius.circular(9),
                ),
                child: Text(
                  'Browse Products',
                  style: AppTypography.body(
                    11,
                    color: Colors.white,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NO MATCH STATE
  // ============================================================

  Widget _noMatch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 50,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                size: 21,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'No matches in this category',
              style: AppTypography.body(
                13,
                color: const Color(0xFF333333),
                weight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Try selecting "All" to see everything',
              style: AppTypography.body(
                11,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STORY CARD
  // ============================================================

  Widget _storyCard(
    BuildContext context,
    dynamic story,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TestimonialDetailScreen(
              testimonial: story,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // ----------------------------------------------------
            // IMAGE
            // ----------------------------------------------------

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(9),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.network(
                  story.coverImage,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      color: AppColors.bg,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.muted,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ----------------------------------------------------
            // DETAILS
            // ----------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                    child: Text(
                      story.type,
                      style: AppTypography.body(
                        9,
                        color: Colors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    story.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: AppTypography.body(
                      12,
                      color:
                          const Color(0xFF333333),
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFFC8CEDF),
            ),
          ],
        ),
      ),
    );
  }
}