import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/product_card.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../state/app_state.dart';
import '../theme/typography.dart';

class ProductListingScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;
  final ProductRepository? repository;

  const ProductListingScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
    this.repository,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  // ============================================================
  // STATE
  // ============================================================

  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _categoryTitle = '';

  int selectedFilter = 0;
  String selectedSort = 'Relevance';
  bool gridView = true;

  final List<String> filters = [
    'All',
    'New',
    'Featured',
    'Tires',
    'Tracks',
  ];

  final List<String> sortOptions = [
    'Relevance',
    'Name A–Z',
    'Newest First',
    'Rating',
  ];

  @override
  void initState() {
    super.initState();
    _categoryTitle = widget.categoryName ?? '';
    _fetchProducts();
  }

  ProductRepository get _repo =>
      widget.repository ?? context.read<AppState>().productRepository;

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prods = await _repo.getProducts(categoryId: widget.categoryId);

      String title = _categoryTitle;
      if (title.isEmpty && prods.isNotEmpty) {
        title = prods.first.categoryName;
      }
      if (title.isEmpty) {
        try {
          final cats = await _repo.getCategories();
          final match = cats.firstWhere(
            (c) =>
                c['id'] == widget.categoryId ||
                c['slug'] == widget.categoryId,
            orElse: () => <String, dynamic>{},
          );
          if (match.isNotEmpty && match['name'] != null) {
            title = match['name'].toString();
          }
        } catch (_) {}
      }
      if (title.isEmpty) {
        title = 'Products';
      }

      if (!mounted) return;
      setState(() {
        _products = prods;
        _categoryTitle = title;
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Apply selected filter
    List<Product> filtered = List<Product>.from(_products);

    switch (filters[selectedFilter]) {
      case 'New':
        filtered = filtered.where((p) => p.isNew).toList();
        break;

      case 'Featured':
        filtered = filtered.where((p) => p.isFeatured).toList();
        break;

      case 'Tires':
        filtered = filtered.where((p) {
          final cat = p.category.toLowerCase();
          return !cat.contains('track') && !cat.contains('excavator');
        }).toList();
        break;

      case 'Tracks':
        filtered = filtered.where((p) {
          final cat = p.category.toLowerCase();
          return cat.contains('track') || cat.contains('excavator');
        }).toList();
        break;

      case 'All':
      default:
        break;
    }

    // Apply sorting
    switch (selectedSort) {
      case 'Name A–Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;

      case 'Newest First':
        filtered.sort(
          (a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0),
        );
        break;

      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'Relevance':
      default:
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // ========================================================
            // HEADER
            // ========================================================
            Container(
              width: double.infinity,
              color: const Color(0xFF203F99),
              padding: const EdgeInsets.fromLTRB(22, 18, 20, 20),
              child: Row(
                children: [
                  // BACK BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  // TITLE + COUNT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _categoryTitle.isNotEmpty ? _categoryTitle : 'Catalogue',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.heading(24).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isLoading
                              ? 'Loading...'
                              : '${filtered.length} products',
                          style: AppTypography.body(
                            12,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // FILTER CHIPS
            // ========================================================
            Container(
              width: double.infinity,
              color: const Color(0xFF203F99),
              padding: const EdgeInsets.fromLTRB(22, 0, 12, 16),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final selected = selectedFilter == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFF5822D)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          filters[index],
                          style: AppTypography.body(
                            13,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ========================================================
            // ORANGE DIVIDER
            // ========================================================
            Container(
              height: 3,
              width: double.infinity,
              color: const Color(0xFFF5822D),
            ),

            // ========================================================
            // SORT + VIEW BAR
            // ========================================================
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  // SORT BUTTON
                  GestureDetector(
                    onTap: () {
                      _showSortMenu(context);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sort,
                          size: 20,
                          color: Color(0xFF333333),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sort: $selectedSort',
                          style: AppTypography.body(
                            14,
                            color: const Color(0xFF333333),
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF333333),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // RESULTS
                  Text(
                    _isLoading ? '...' : '${filtered.length} results',
                    style: AppTypography.body(
                      13,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // GRID / LIST TOGGLE
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        gridView = !gridView;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        gridView ? Icons.grid_view : Icons.view_list,
                        size: 20,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // PRODUCTS LIST / GRID / STATES
            // ========================================================
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : filtered.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              color: const Color(0xFF203F99),
                              onRefresh: _fetchProducts,
                              child: gridView
                                  ? _buildGrid(filtered)
                                  : _buildList(filtered),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LOADING STATE
  // ================================================================

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF203F99),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fetching products...',
            style: AppTypography.body(
              14,
              color: const Color(0xFF6B7280),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load products',
                style: AppTypography.heading(18).copyWith(
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unable to connect to product server.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  13,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203F99),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF1FA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search,
                size: 30,
                color: Color(0xFF203F99),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: AppTypography.body(
                15,
                color: const Color(0xFF333333),
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No items match the selected category or filter.\nTry clearing or changing your filters.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                13,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 18),
            if (selectedFilter != 0)
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF203F99),
                  side: const BorderSide(color: Color(0xFF203F99)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Reset Filters'),
              ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // GRID
  // ================================================================

  Widget _buildGrid(List<Product> filtered) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filtered[index],
        );
      },
    );
  }

  // ================================================================
  // LIST
  // ================================================================

  Widget _buildList(List<Product> filtered) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return ProductCard(
          product: filtered[index],
          compact: true,
        );
      },
    );
  }

  // ================================================================
  // SORT BOTTOM SHEET
  // ================================================================

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort Products',
                  style: AppTypography.heading(21).copyWith(
                    color: const Color(0xFF203F99),
                  ),
                ),
                const SizedBox(height: 12),
                ...sortOptions.map(
                  (option) {
                    final selected = selectedSort == option;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedSort = option;
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFEEF1FA)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: AppTypography.body(
                                  14,
                                  color: selected
                                      ? const Color(0xFF203F99)
                                      : const Color(0xFF333333),
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check,
                                size: 19,
                                color: Color(0xFF203F99),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}