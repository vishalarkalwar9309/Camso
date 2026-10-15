import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String activeFilter = 'All';
  int feedbackTab = 0;

  Map<String, dynamic>? _catalogueAnalytics;
  Map<String, dynamic>? _contentAnalytics;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AppState>().permissions.canViewAdminAnalytics) {
        _loadAdminAnalytics();
      }
    });
  }

  Future<void> _loadAdminAnalytics() async {
    setState(() {
      _isLoadingAnalytics = true;
      _analyticsError = null;
    });
    try {
      final repo = context.read<AppState>().contentRepository;
      final results = await Future.wait([
        repo.getCatalogueAnalytics(limit: 10),
        repo.getContentAnalytics(),
      ]);
      if (mounted) {
        setState(() {
          _catalogueAnalytics = results[0];
          _contentAnalytics = results[1];
          _isLoadingAnalytics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analyticsError = e.toString();
          _isLoadingAnalytics = false;
        });
      }
    }
  }

  // ================================================================
  // USER ACTIVITY DATA
  // ================================================================

  final List<Map<String, dynamic>> userActivity = [
    {
      'type': 'feedback',
      'title': 'Submitted product feedback',
      'detail': 'STA 550 Steel Track Assembly',
      'meta': '5 stars',
      'date': '20 Aug 2026',
    },
    {
      'type': 'product_view',
      'title': 'Viewed product',
      'detail': 'STA 550 Steel Track Assembly',
      'meta': 'Steel Tracks',
      'date': '20 Aug 2026',
    },
    {
      'type': 'document_download',
      'title': 'Downloaded document',
      'detail': 'SKS S1 Installation Manual',
      'meta': 'Installation Manual',
      'date': '20 Aug 2026',
    },
    {
      'type': 'bookmark',
      'title': 'Bookmarked product',
      'detail': 'STA 550 Steel Track Assembly',
      'meta': null,
      'date': '19 Aug 2026',
    },
    {
      'type': 'search',
      'title': 'Searched products',
      'detail': 'Steel Tracks',
      'meta': null,
      'date': '19 Aug 2026',
    },
    {
      'type': 'product_view',
      'title': 'Viewed product',
      'detail': 'Backhoe Tires',
      'meta': 'Backhoe Tires',
      'date': '18 Aug 2026',
    },
    {
      'type': 'support_contact',
      'title': 'Contacted support',
      'detail': 'Technical support enquiry',
      'meta': null,
      'date': '18 Aug 2026',
    },
    {
      'type': 'dealer_locate',
      'title': 'Located a dealer',
      'detail': 'Dealer search',
      'meta': 'Pune',
      'date': '17 Aug 2026',
    },
  ];

  // ================================================================
  // ADMIN DATA
  // ================================================================

  final List<Map<String, dynamic>> pageTimeData = [
    {'page': 'Home', 'seconds': 42},
    {'page': 'Products', 'seconds': 86},
    {'page': 'Product Detail', 'seconds': 124},
    {'page': 'Support', 'seconds': 68},
    {'page': 'Documents', 'seconds': 95},
  ];

  final List<Map<String, dynamic>> productDemandData = [
    {
      'name': 'STA 550 Steel Track Assembly',
      'pid': 'STA550-450X83.5X71',
      'views': 1840,
      'bookmarks': 324,
    },
    {
      'name': 'Skid Steer Tires',
      'pid': 'SKD-10-16.5',
      'views': 1520,
      'bookmarks': 241,
    },
    {
      'name': 'Telehandler Tires',
      'pid': 'TEL-400-80R24',
      'views': 1210,
      'bookmarks': 198,
    },
    {
      'name': 'Rubber Tracks',
      'pid': 'RT-450X86X60',
      'views': 980,
      'bookmarks': 154,
    },
  ];

  final List<Map<String, dynamic>> documentDownloads = [
    {
      'title': 'SKS S1 Installation Manual',
      'downloads': 1240,
    },
    {
      'title': 'CAMSO Product Catalog 2024–25',
      'downloads': 980,
    },
    {
      'title': 'Steel Track Maintenance Guide',
      'downloads': 742,
    },
    {
      'title': 'Warranty Documentation',
      'downloads': 521,
    },
  ];

  final List<Map<String, dynamic>> adminFeedbacks = [
    {
      'user': 'Rajesh Kumar',
      'role': 'Dealer',
      'rating': 5,
      'text':
          'The product information is very detailed and the documentation is easy to find.',
      'date': '20 Aug 2026',
    },
    {
      'user': 'Amit Sharma',
      'role': 'Distributor',
      'rating': 4,
      'text':
          'Very useful application for quickly checking product specifications.',
      'date': '19 Aug 2026',
    },
    {
      'user': 'Priya Mehta',
      'role': 'Customer',
      'rating': 5,
      'text':
          'The support library makes it much easier to find installation manuals.',
      'date': '18 Aug 2026',
    },
  ];

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = context.watch<AppState>().permissions.canViewAdminAnalytics;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),

            Expanded(
              child: isAdmin
                  ? _adminDashboard()
                  : _userActivity(),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _header(BuildContext context) {
    final bool isAdmin =
      context.read<AppState>().permissions.canViewAdminAnalytics;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16,
      ),
      color: AppColors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    if (Navigator.of(context).canPop()) ...[
      IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        tooltip: 'Back',
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 8),
    ],
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAdmin ? 'ADMIN ANALYTICS' : 'MY ACTIVITY',
            style: AppTypography.heading(26).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAdmin
                ? 'Collective user analytics'
                : 'Your app usage history',
            style: AppTypography.body(
              12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ),
  ],
),
        ],
      ),
    );
  }

  // ================================================================
  // USER ACTIVITY
  // ================================================================

  Widget _userActivity() {
    final filtered = activeFilter == 'All'
        ? userActivity
        : userActivity.where((e) {
            switch (activeFilter) {
              case 'Feedback':
                return e['type'] == 'feedback';
              case 'Products':
                return e['type'] == 'product_view';
              case 'Downloads':
                return e['type'] == 'document_download';
              case 'Bookmarks':
                return e['type'] == 'bookmark';
              case 'Searches':
                return e['type'] == 'search';
              default:
                return true;
            }
          }).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ------------------------------------------------------------
        // SUMMARY
        // ------------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Actions',
                  userActivity.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Feedbacks',
                  userActivity
                      .where((e) => e['type'] == 'feedback')
                      .length
                      .toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Downloads',
                  userActivity
                      .where(
                        (e) => e['type'] == 'document_download',
                      )
                      .length
                      .toString(),
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------------------
        // FILTERS
        // ------------------------------------------------------------

        SizedBox(
          height: 55,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: [
              'All',
              'Feedback',
              'Products',
              'Downloads',
              'Bookmarks',
              'Searches',
            ].map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _filterChip(filter),
              );
            }).toList(),
          ),
        ),

        // ------------------------------------------------------------
        // TIMELINE
        // ------------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            24,
          ),
          child: filtered.isEmpty
              ? _emptyActivity()
              : _activityTimeline(filtered),
        ),
      ],
    );
  }

  // ================================================================
  // SUMMARY CARD
  // ================================================================

  Widget _summaryCard(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.heading(24).copyWith(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.body(
              10,
              color: AppColors.muted,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // FILTER CHIP
  // ================================================================

  Widget _filterChip(String label) {
    final selected = activeFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          activeFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body(
            11,
            color: selected
                ? Colors.white
                : const Color(0xFF555555),
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ACTIVITY TIMELINE
  // ================================================================

  Widget _activityTimeline(
    List<Map<String, dynamic>> events,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final event in events) {
      final date = event['date'] as String;

      grouped.putIfAbsent(
        date,
        () => [],
      );

      grouped[date]!.add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 2,
                ),
                child: Text(
                  entry.key.toUpperCase(),
                  style: AppTypography.body(
                    10,
                    color: AppColors.muted,
                    weight: FontWeight.w600,
                  ).copyWith(
                    letterSpacing: 1,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: List.generate(
                    entry.value.length,
                    (index) {
                      final event =
                          entry.value[index];

                      return _activityTile(
                        event,
                        index <
                            entry.value.length - 1,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // ACTIVITY TILE
  // ================================================================

  Widget _activityTile(
    Map<String, dynamic> event,
    bool showDivider,
  ) {
    final config =
        _eventConfig(event['type']);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFF2F4F8),
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(
              top: 2,
            ),
            decoration: BoxDecoration(
              color: config['bg'],
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              config['icon'],
              size: 15,
              color: config['fg'],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: AppTypography.body(
                    12,
                    color: const Color(0xFF333333),
                    weight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  event['detail'],
                  style: AppTypography.body(
                    11,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                if (event['meta'] != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: config['bg'],
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                    child: Text(
                      event['meta'],
                      style: AppTypography.body(
                        9,
                        color: config['fg'],
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 6),

          Text(
            'Recent',
            style: AppTypography.body(
              9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // EVENT CONFIG
  // ================================================================

  Map<String, dynamic> _eventConfig(
    String type,
  ) {
    switch (type) {
      case 'feedback':
        return {
          'bg': const Color(0xFFEEF1FA),
          'fg': AppColors.blue,
          'icon': Icons.chat_bubble_outline,
        };

      case 'product_view':
        return {
          'bg': const Color(0xFFFFF3EA),
          'fg': AppColors.orange,
          'icon': Icons.visibility_outlined,
        };

      case 'document_download':
        return {
          'bg': const Color(0xFFECFDF5),
          'fg': const Color(0xFF059669),
          'icon': Icons.download_outlined,
        };

      case 'bookmark':
        return {
          'bg': const Color(0xFFEEF1FA),
          'fg': AppColors.blue,
          'icon': Icons.bookmark,
        };

      case 'search':
        return {
          'bg': const Color(0xFFF5F5F6),
          'fg': const Color(0xFF6B7280),
          'icon': Icons.search,
        };

      case 'support_contact':
        return {
          'bg': const Color(0xFFFEF3C7),
          'fg': const Color(0xFFD97706),
          'icon': Icons.phone_outlined,
        };

      case 'dealer_locate':
        return {
          'bg': const Color(0xFFFFF3EA),
          'fg': AppColors.orange,
          'icon': Icons.location_on_outlined,
        };

      default:
        return {
          'bg': const Color(0xFFF5F5F6),
          'fg': const Color(0xFF6B7280),
          'icon': Icons.history,
        };
    }
  }

  // ================================================================
  // EMPTY ACTIVITY
  // ================================================================

  Widget _emptyActivity() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.blue,
              size: 27,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No activity yet',
            style: AppTypography.body(
              13,
              color: const Color(0xFF333333),
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ADMIN DASHBOARD
  // ================================================================

  Widget _adminDashboard() {
    if (_isLoadingAnalytics) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_analyticsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textSubtle),
              const SizedBox(height: 12),
              Text(
                _analyticsError!,
                textAlign: TextAlign.center,
                style: AppTypography.body(14, color: AppColors.textSubtle),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAdminAnalytics,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final catSummary = _catalogueAnalytics?['summary'] as Map<String, dynamic>?;
    final feedbackMetrics = _contentAnalytics?['feedback_metrics'] as Map<String, dynamic>?;
    final totalFeedbacks = feedbackMetrics?['total_feedback']?.toString() ??
        feedbackMetrics?['total']?.toString() ??
        '0';
    final avgRating = feedbackMetrics?['average_rating'] != null
        ? (feedbackMetrics!['average_rating'] as num).toStringAsFixed(1)
        : '5.0';
    final totalBookmarks = catSummary?['total_bookmarks']?.toString() ??
        catSummary?['totalBookmarks']?.toString() ??
        '0';
    final totalProducts = catSummary?['total_products']?.toString() ??
        catSummary?['totalProducts']?.toString() ??
        '12';

    return ListView(
      padding: const EdgeInsets.only(
        bottom: 24,
      ),
      children: [
        // ============================================================
        // PLATFORM OVERVIEW
        // ============================================================

        _adminSection(
          title: 'PLATFORM OVERVIEW',
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _kpiCard(
                'Catalogue Products',
                totalProducts,
                'active in catalog',
                AppColors.blue,
              ),
              _kpiCard(
                'Total Bookmarks',
                totalBookmarks,
                'user bookmarks',
                AppColors.orange,
              ),
              _kpiCard(
                'Total Feedbacks',
                totalFeedbacks,
                'submitted feedback',
                const Color(0xFF059669),
              ),
              _kpiCard(
                'Avg App Rating',
                avgRating,
                '/ 5.0 stars',
                AppColors.blue,
              ),
            ],
          ),
        ),

        // ============================================================
        // TIME PER SCREEN
        // ============================================================

        _adminSection(
          title: 'AVG TIME PER SCREEN',
          child: _timeChart(),
        ),

        // ============================================================
        // PRODUCT DEMAND
        // ============================================================

        _adminSection(
          title: 'PRODUCT DEMAND',
          trailing: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'PDF export can be connected here.',
                  ),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_outlined,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Export PDF',
                    style: AppTypography.body(
                      10,
                      color: Colors.white,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: _productDemand(),
        ),

        // ============================================================
        // DOCUMENT DOWNLOADS
        // ============================================================

        _adminSection(
          title: 'DOCUMENT DOWNLOADS',
          child: _documentDownloads(),
        ),

        // ============================================================
        // USER FEEDBACKS
        // ============================================================

        _adminSection(
          title: 'USER FEEDBACKS',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _feedbackToggle(
                'All',
                0,
              ),
              const SizedBox(width: 5),
              _feedbackToggle(
                'Recent',
                1,
              ),
            ],
          ),
          child: Column(
            children: adminFeedbacks
                .map(_feedbackCard)
                .toList(),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ADMIN SECTION
  // ================================================================

  Widget _adminSection({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.body(
                    10,
                    color: AppColors.muted,
                    weight: FontWeight.w600,
                  ).copyWith(
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 10),

          child,
        ],
      ),
    );
  }

  // ================================================================
  // KPI CARD
  // ================================================================

  Widget _kpiCard(
    String label,
    String value,
    String sub,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.heading(28).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: AppTypography.body(
              10,
              color: const Color(0xFF333333),
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            sub,
            style: AppTypography.body(
              9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TIME CHART
  // ================================================================

  Widget _timeChart() {
    final maxSeconds = pageTimeData
        .map((e) => e['seconds'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: pageTimeData.map((row) {
          final seconds = row['seconds'] as int;

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 14,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row['page'],
                      style: AppTypography.body(
                        11,
                        color: const Color(0xFF333333),
                        weight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      seconds >= 60
                          ? '${seconds ~/ 60}m ${seconds % 60}s'
                          : '${seconds}s',
                      style: AppTypography.body(
                        11,
                        color: AppColors.blue,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                        seconds / maxSeconds,
                    minHeight: 7,
                    backgroundColor:
                        AppColors.bg,
                    valueColor:
                        const AlwaysStoppedAnimation(
                      AppColors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================================================================
  // PRODUCT DEMAND
  // ================================================================

  Widget _productDemand() {
    final rawList = _catalogueAnalytics?['most_bookmarked_products'] as List?;
    final demandList = (rawList != null && rawList.isNotEmpty)
        ? rawList.map((p) => <String, dynamic>{
              'name': p['title'] ?? p['name'] ?? 'Product',
              'pid': p['id']?.toString() ?? '',
              'views': (p['views'] as int?) ?? 100,
              'bookmarks': (p['bookmark_count'] as int?) ?? (p['bookmarks'] as int?) ?? 1,
            }).toList()
        : productDemandData;

    final maxViews = (demandList.isNotEmpty && demandList.first['views'] is int && (demandList.first['views'] as int) > 0)
        ? demandList.first['views'] as int
        : 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: demandList
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final product = entry.value;
          final views = (product['views'] as int?) ?? 0;
          final bookmarks = (product['bookmarks'] as int?) ?? 0;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: index <
                      productDemandData.length - 1
                  ? const Border(
                      bottom: BorderSide(
                        color: Color(0xFFF2F4F8),
                      ),
                    )
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: AppTypography.body(
                              11,
                              color:
                                  const Color(0xFF333333),
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product['pid'],
                            style: AppTypography.body(
                              9,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(views),
                          style:
                              AppTypography.body(
                            11,
                            color: AppColors.blue,
                            weight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'views',
                          style:
                              AppTypography.body(
                            9,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 7),

                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFFC8CEDF),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child:
                          LinearProgressIndicator(
                        value: views / maxViews,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.bg,
                        valueColor:
                            const AlwaysStoppedAnimation(
                          AppColors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '🔖 ${_formatNumber(bookmarks)}',
                      style: AppTypography.body(
                        9,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================================================================
  // DOCUMENT DOWNLOADS
  // ================================================================

  Widget _documentDownloads() {
    final rawDocs = _contentAnalytics?['top_downloaded_documents'] as List?;
    final docsList = (rawDocs != null && rawDocs.isNotEmpty)
        ? rawDocs.map((d) => <String, dynamic>{
              'title': d['title'] ?? 'Document',
              'downloads': (d['download_count'] as int?) ?? (d['downloads'] as int?) ?? 0,
            }).toList()
        : documentDownloads;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: docsList
            .asMap()
            .entries
            .map((entry) {
          final index = entry.key;
          final document = entry.value;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              border: index <
                      documentDownloads.length - 1
                  ? const Border(
                      bottom: BorderSide(
                        color: Color(0xFFF2F4F8),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 15,
                    color: Color(0xFF059669),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        document['title'],
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: AppTypography.body(
                          11,
                          color: AppColors.blue,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatNumber(document['downloads'])} downloads total',
                        style: AppTypography.body(
                          9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  _formatNumber(
                    document['downloads'],
                  ),
                  style: AppTypography.body(
                    11,
                    color: const Color(0xFF059669),
                    weight: FontWeight.w700,
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Color(0xFFC8CEDF),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================================================================
  // FEEDBACK TOGGLE
  // ================================================================

  Widget _feedbackToggle(
    String label,
    int index,
  ) {
    final selected =
        feedbackTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          feedbackTab = index;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.blue
              : AppColors.bg,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.body(
            10,
            color: selected
                ? Colors.white
                : const Color(0xFF6B7280),
            weight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // FEEDBACK CARD
  // ================================================================

  Widget _feedbackCard(
    Map<String, dynamic> feedback,
  ) {
    final rating = feedback['rating'] as int;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['user'],
                      style: AppTypography.body(
                        11,
                        color:
                            const Color(0xFF333333),
                        weight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius:
                            BorderRadius.circular(4),
                      ),
                      child: Text(
                        feedback['role'],
                        style: AppTypography.body(
                          9,
                          color: AppColors.blue,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 11,
                    color: index < rating
                        ? _ratingColor(rating)
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Text(
            '"${feedback['text']}"',
            style: AppTypography.body(
              11,
              color: const Color(0xFF555555),
            ).copyWith(
              height: 1.45,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            feedback['date'],
            style: AppTypography.body(
              9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HELPERS
  // ================================================================

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }

    return number.toString();
  }

  Color _ratingColor(int rating) {
    const colors = [
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFFEAB308),
      Color(0xFF84CC16),
      Color(0xFF22C55E),
    ];

    return colors[
        (rating - 1).clamp(0, 4)];
  }
}