import 'dart:async';
import 'package:flutter/material.dart';

import '../data/mock_data.dart' as mock;
import '../models/product.dart';
import '../repositories/search_repository.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/product_card.dart';

class SearchScreen extends StatefulWidget {
  final SearchRepository? searchRepository;

  const SearchScreen({super.key, this.searchRepository});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchRepository _searchRepository;
  bool _showAllApplications = false;

  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  String query = '';
  String? selectedApplication;

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _results = [];

  List<String> recentSearches = [
    'SKS S1',
    'rubber track 400',
    'telehandler tire',
    'CTL 400',
  ];

  List<String> popularSearches = [
    'skid steer',
    'mini excavator',
    '10-16.5',
    'rubber tracks',
    'telehandler',
    'backhoe',
  ];

  @override
  void initState() {
    super.initState();
    _searchRepository = widget.searchRepository ?? SearchRepository();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final popular = await _searchRepository.getPopularSearches();
      final recent = await _searchRepository.getRecentSearches();
      if (!mounted) return;
      setState(() {
        if (popular.isNotEmpty) popularSearches = popular;
        if (recent.isNotEmpty) recentSearches = recent;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ================================================================
  // ADD TO RECENT SEARCHES
  // ================================================================

  void addToRecentSearches(String search) {
    final trimmed = search.trim();
    if (trimmed.isEmpty) return;

    _searchRepository.addRecentSearch(trimmed);
    setState(() {
      recentSearches = [
        trimmed,
        ...recentSearches.where(
          (item) => item.toLowerCase() != trimmed.toLowerCase(),
        ),
      ].take(6).toList();
    });
  }

  // ================================================================
  // HANDLE SEARCH
  // ================================================================

  void handleSearch(String search) {
    final trimmed = search.trim();
    _debounceTimer?.cancel();

    setState(() {
      query = trimmed;
    });

    if (trimmed.isNotEmpty) {
      addToRecentSearches(trimmed);
    }

    _performSearch();
  }

  void _onQueryChanged(String value) {
    setState(() {
      query = value;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final q = query.trim();
    final hasFilter = selectedApplication != null;

    if (q.length < 2 && !hasFilter) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _searchRepository.searchProducts(
        q,
        categoryId: selectedApplication,
      );
      if (!mounted) return;
      setState(() {
        _results = items;
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

  // ================================================================
  // CLEAR SEARCH TEXT
  // ================================================================

  void clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();

    setState(() {
      query = '';
      _errorMessage = null;
    });

    _performSearch();
  }

  // ================================================================
  // CLEAR APPLICATION FILTER
  // ================================================================

  void clearApplicationFilter() {
    setState(() {
      selectedApplication = null;
    });
    _performSearch();
  }

  // ================================================================
  // CLEAR ALL RECENT SEARCHES
  // ================================================================

  void clearAllRecent() {
    _searchRepository.clearRecentSearches();
    setState(() {
      recentSearches = [];
    });
  }

  // ================================================================
  // SET SEARCH FROM A CHIP
  // ================================================================

  void selectSearch(String search) {
    _controller.text = search;
    handleSearch(search);
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final applications = mock.products
        .expand((product) => product.applications)
        .map((application) => application.trim())
        .where((application) => application.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final visibleApplications = _showAllApplications
        ? applications
        : applications.take(6).toList();

    final showResults = query.trim().length >= 2 || selectedApplication != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              color: AppColors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEARCH',
                    style: AppTypography.heading(
                      28,
                      color: Colors.white,
                      weight: FontWeight.w800,
                    ).copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // SEARCH FIELD
                  // ------------------------------------------------

                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 19,
                          color: AppColors.muted,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: _onQueryChanged,
                            onSubmitted: handleSearch,
                            style: AppTypography.body(
                              13,
                              color: const Color(0xFF333333),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search products, PID or size',
                              hintStyle: AppTypography.body(
                                12,
                                color: AppColors.muted,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        // Clear the typed search query.
                        if (query.isNotEmpty)
                          IconButton(
                            onPressed: clearSearch,
                            tooltip: 'Clear search text',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ------------------------------------------------
                  // SELECTED APPLICATION INDICATOR
                  // ------------------------------------------------

                  if (selectedApplication != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.filter_alt_outlined,
                                size: 15,
                                color: AppColors.blue,
                              ),

                              const SizedBox(width: 6),

                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 220,
                                ),
                                child: Text(
                                  selectedApplication!,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    12,
                                    color: AppColors.blue,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 6),

                              InkWell(
                                onTap: clearApplicationFilter,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: AppColors.muted,
                                  ),
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

            // ======================================================
            // ORANGE LINE
            // ======================================================

            Container(
              height: 2,
              color: AppColors.orange,
            ),

            // ======================================================
            // CONTENT
            // ======================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(strokeWidth: 3),
                            SizedBox(height: 14),
                            Text('Searching CAMSO catalogue...', style: TextStyle(color: AppColors.muted)),
                          ],
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 32),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _performSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry Search'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (showResults && _results.isNotEmpty)
                    _buildResults(_results)
                  else if (showResults && _results.isEmpty)
                    _buildNoResults(context, query)
                  else
                    _buildDefaultContent(
                      context,
                      applications,
                      visibleApplications,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  // ================================================================
  // DEFAULT CONTENT
  // ================================================================

  Widget _buildDefaultContent(
    BuildContext context,
    List<String> applications,
    List<String> visibleApplications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // RECENT SEARCHES
        // ==========================================================

        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('RECENT SEARCHES'),

              TextButton(
                onPressed: clearAllRecent,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear all',
                  style: AppTypography.body(
                    11,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Recent search chips.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return GestureDetector(
                onTap: () => selectSearch(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 13,
                        color: AppColors.muted,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        search,
                        style: AppTypography.body(
                          12,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),
        ],

        // ==========================================================
        // BROWSE BY APPLICATION
        // ==========================================================

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('BROWSE BY APPLICATION'),

            if (selectedApplication != null)
              TextButton(
                onPressed: clearApplicationFilter,
                child: const Text('Clear'),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Show six applications by default.
        // "See All" reveals the remaining applications.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: visibleApplications.map((application) {
            final selected =
                selectedApplication?.toLowerCase() ==
                    application.toLowerCase();

            return ChoiceChip(
              label: Text(application),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  selectedApplication =
                      isSelected ? application : null;
                });
              },
              selectedColor: AppColors.lightBlue,
              labelStyle: AppTypography.body(
                12,
                color: selected ? AppColors.blue : AppColors.body,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              side: BorderSide(
                color: selected ? AppColors.blue : AppColors.border,
              ),
              backgroundColor: Colors.white,
              showCheckmark: false,
            );
          }).toList(),
        ),

        if (applications.length > 6)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllApplications = !_showAllApplications;
                });
              },
              child: Text(
                _showAllApplications ? 'See Less' : 'See All',
              ),
            ),
          ),

        const SizedBox(height: 28),

        // ==========================================================
        // POPULAR SEARCHES
        // ==========================================================

        _sectionTitle('POPULAR'),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches.map((search) {
            return GestureDetector(
              onTap: () => selectSearch(search),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  search,
                  style: AppTypography.body(
                    11,
                    color: AppColors.blue,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

      ],
    );
  }

  // ================================================================
  // SEARCH RESULTS
  // ================================================================

  Widget _buildResults(List<dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedApplication != null && query.trim().length < 2
              ? '${results.length} result'
                  '${results.length != 1 ? 's' : ''} in $selectedApplication'
              : '${results.length} result'
                  '${results.length != 1 ? 's' : ''} for "$query"',
          style: AppTypography.body(
            12,
            color: AppColors.body,
          ),
        ),

        const SizedBox(height: 16),

        Column(
          children: results.map((product) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ProductCard(
                product: product,
                compact: true,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ================================================================
  // NO RESULTS
  // ================================================================

  Widget _buildNoResults(
    BuildContext context,
    String search,
  ) {
    final message = search.trim().isNotEmpty
        ? 'No results found for "${search.trim()}"'
        : 'No products found for "$selectedApplication"';

    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 30,
              color: AppColors.blue,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              14,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Try another product name, PID or size.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              11,
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {
                // Connect your Contact Support screen here if available.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CONTACT SUPPORT',
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
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.body(
        11,
        color: AppColors.muted,
        weight: FontWeight.w700,
      ).copyWith(
        letterSpacing: 1.2,
      ),
    );
  }
}