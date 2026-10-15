import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/product_repository.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'product_listing_screen.dart';

class ProductsScreen extends StatefulWidget {
  final ProductRepository? repository;

  const ProductsScreen({super.key, this.repository});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> _categories = [];
  int _totalProducts = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  ProductRepository get _repo =>
      widget.repository ?? context.read<AppState>().productRepository;

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getProducts(pageSize: 100),
      ]);

      if (!mounted) return;

      final cats = results[0] as List<Map<String, dynamic>>;
      final prods = results[1] as List<dynamic>;

      setState(() {
        _categories = cats;
        _totalProducts = prods.length;
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

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 20, 20, 20),
              color: const Color(0xFF203F99),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRODUCTS',
                          style: AppTypography.heading(28).copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Compact Construction Range',
                          style: AppTypography.body(
                            12,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search button triggers search tab
                  GestureDetector(
                    onTap: () {
                      state.setTab(2);
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // ORANGE STRIP
            // ============================================================
            Container(
              height: 4,
              width: double.infinity,
              color: const Color(0xFFF5822D),
            ),

            // ============================================================
            // MAIN CONTENT
            // ============================================================
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF203F99),
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                  child: Column(
                    children: [
                      // STATISTICS
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              value: _isLoading ? '...' : '$_totalProducts',
                              label: 'Total Products',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _statCard(
                              value: _isLoading ? '...' : '${_categories.length}',
                              label: 'Categories',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // CONDITIONAL STATE BODY
                      if (_isLoading) ...[
                        _buildLoadingState(),
                      ] else if (_errorMessage != null) ...[
                        _buildErrorState(),
                      ] else if (_categories.isEmpty) ...[
                        _buildEmptyState(),
                      ] else ...[
                        // CATEGORY LIST
                        Column(
                          children: List.generate(
                            _categories.length,
                            (index) {
                              final category = _categories[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _categories.length - 1 ? 0 : 14,
                                ),
                                child: _categoryCard(context, category, index),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // LOADING STATE
  // ======================================================================

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF203F99),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: AppTypography.body(
              13,
              color: const Color(0xFF6B7280),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // ERROR STATE
  // ======================================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Unable to Load Catalogue',
            style: AppTypography.heading(18).copyWith(
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? 'A network or server error occurred.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF203F99),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // EMPTY STATE
  // ======================================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF9CA3AF),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No Categories Available',
            style: AppTypography.heading(17).copyWith(
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back soon or pull down to refresh.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              13,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // STAT CARD
  // ======================================================================

  Widget _statCard({
    required String value,
    required String label,
  }) {
    return Container(
      height: 123,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.heading(30).copyWith(
              color: const Color(0xFF203F99),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.body(
              11,
              color: const Color(0xFF9CA3AF),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // CATEGORY CARD
  // ======================================================================

  Widget _categoryCard(
    BuildContext context,
    Map<String, dynamic> category,
    int index,
  ) {
    final catId = category['id']?.toString().isNotEmpty == true
        ? category['id'].toString()
        : category['slug']?.toString() ?? '';
    final catName = category['name']?.toString() ?? 'Category';
    final imageUrl = category['image']?.toString() ??
        category['icon_url']?.toString() ??
        '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListingScreen(
              categoryId: catId,
              categoryName: catName,
            ),
          ),
        );
      },
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // IMAGE
            SizedBox(
              width: 108,
              height: 88,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFF2F4F8),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFFF2F4F8),
                      child: const Icon(
                        Icons.category_outlined,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
            ),

            // CATEGORY INFORMATION
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
                child: Row(
                  children: [
                    // NAME + COUNT
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.heading(17).copyWith(
                              color: const Color(0xFF203F99),
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            category['count'] != null
                                ? '${category['count']} products'
                                : 'Explore range',
                            style: AppTypography.body(
                              12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // NEW BADGE
                    if (index < 2) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5822D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // CHEVRON
                    const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: Color(0xFF9CA3AF),
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
}