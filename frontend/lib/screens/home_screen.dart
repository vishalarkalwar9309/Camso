import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/product.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/product_card.dart';

import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'product_listing_screen.dart';
import 'product_updates_screen.dart';
import 'support_screen.dart';
import 'bookmarks_screen.dart';
import 'dealer_support_screen.dart';
import 'voc_feedback_screen.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'testimonials_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int slideIndex = 0;

  Timer? _timer;

  final PageController _pageController =
      PageController();

  List<Product> _featuredProducts = [];
  List<Map<String, dynamic>> _homeCategories = [];
  bool _catalogueLoading = true;
  String? _catalogueError;

  // ============================================================
  // CAROUSEL
  // ============================================================

  final List<Map<String, String>> carouselSlides = [
    {
      'url':
          'https://images.unsplash.com/photo-1763516763259-4f7ce3d19c2b?w=800&h=400&fit=crop&auto=format',
      'label': 'Built for the toughest terrain',
      'sub': 'CAMSO Rubber Tracks',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1763516763181-4372f2987360?w=800&h=400&fit=crop&auto=format',
      'label': 'Skid Steer — Maximum traction',
      'sub': 'SKS S1 Series',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1763515187944-821eaca2426b?w=800&h=400&fit=crop&auto=format',
      'label': 'Performance on every surface',
      'sub': 'CAMSO by CEAT',
    },
    {
      'url':
          'https://images.unsplash.com/photo-1763515188384-b69b519e4915?w=800&h=400&fit=crop&auto=format',
      'label': 'Reliability. Precision. Power.',
      'sub': 'XTR 770 Extreme Terrain',
    },
  ];

  @override
  void initState() {
    super.initState();

    _startTimer();
    _loadCatalogue();
  }

  Future<void> _loadCatalogue() async {
    if (!mounted) return;
    setState(() {
      _catalogueLoading = true;
      _catalogueError = null;
    });

    try {
      final repo = context.read<AppState>().productRepository;
      final results = await Future.wait([
        repo.getCategories(),
        repo.getProducts(pageSize: 50),
      ]);

      if (!mounted) return;
      final cats = results[0] as List<Map<String, dynamic>>;
      final prods = results[1] as List<Product>;
      final feat = prods.where((p) => p.isFeatured).toList();

      setState(() {
        _homeCategories = cats;
        _featuredProducts = feat.isNotEmpty ? feat : prods.take(6).toList();
        _catalogueLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogueError = e.toString();
        _catalogueLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 3800),
      (_) {
        if (!_pageController.hasClients) {
          return;
        }

        final next =
            (slideIndex + 1) %
                carouselSlides.length;

        _pageController.animateToPage(
          next,
          duration:
              const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  void _goToSlide(int index) {
    _timer?.cancel();

    setState(() {
      slideIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration:
            const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(
    BuildContext context,
    String screen,
  ) {
    Widget? page;

    switch (screen) {
      case 'notifications':
        page = const NotificationsScreen();
        break;

      case 'profile':
        page = const ProfileScreen();
        break;

      case 'support':
        page = const SupportScreen();
        break;

      case 'bookmarks':
        page = const BookmarksScreen();
        break;

      case 'dealer-support':
        page = const DealerSupportScreen();
        break;

      case 'voc-feedback':
        page = const VOCFeedbackScreen();
        break;

      case 'faq':
        page = const FAQScreen();
        break;

      case 'contact-support':
        page = const ContactSupportScreen();
        break;

      case 'testimonials':
        page = const TestimonialsScreen();
        break;

      case 'product-updates':
        page = const ProductUpdatesScreen();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page!,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state =
        context.watch<AppState>();

    final featured = _featuredProducts;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF2F4F8),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const ClampingScrollPhysics(),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        20,
                      ),
                      color:
                          const Color(0xFF203F99),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'CAMSO',
                                      style:
                                          AppTypography
                                              .heading(
                                        24,
                                      ).copyWith(
                                        color:
                                            Colors.white,
                                        letterSpacing:
                                            2.4,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 2,
                                    ),

                                    Text(
                                      'Your construction tire & track companion',
                                      style:
                                          AppTypography
                                              .body(
                                        12,
                                        color:
                                            Colors.white
                                                .withValues(
                                          alpha:
                                              0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Notification
                              Stack(
                                clipBehavior:
                                    Clip.none,
                                children: [
                                  _headerButton(
                                    icon: Icons
                                        .notifications_none,
                                    onTap: () {
                                      _navigate(
                                        context,
                                        'notifications',
                                      );
                                    },
                                  ),

                                  if (state.unreadCount >
                                      0)
                                    Positioned(
                                      top: -1,
                                      right: -1,
                                      child:
                                          Container(
                                        width: 16,
                                        height: 16,
                                        decoration:
                                            const BoxDecoration(
                                          color:
                                              Color(
                                            0xFFF5822D,
                                          ),
                                          shape:
                                              BoxShape
                                                  .circle,
                                        ),
                                        alignment:
                                            Alignment
                                                .center,
                                        child:
                                            Text(
                                          '${state.unreadCount}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white,
                                            fontSize:
                                                9,
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              // Profile
                              _headerButton(
                                icon:
                                    Icons.person_outline,
                                onTap: () {
                                  _navigate(
                                    context,
                                    'profile',
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // SEARCH
                          GestureDetector(
                            onTap: () {
                              state.setTab(2);
                            },
                            child: Container(
                              width:
                                  double.infinity,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 17,
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha: 0.8,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Text(
                                    'Search products, PID or size',
                                    style:
                                        AppTypography
                                            .body(
                                      13,
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
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // ORANGE STRIP
                    // ==================================================

                    Container(
                      height: 4,
                      width: double.infinity,
                      color:
                          const Color(0xFFF5822D),
                    ),

                    // ==================================================
                    // MAIN CONTENT
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          // ==================================================
                          // IMAGE CAROUSEL
                          // ==================================================

                          Padding(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              24,
                              20,
                              0,
                            ),
                            child: SizedBox(
                              height: 176,
                              width:
                                  double.infinity,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      controller:
                                          _pageController,
                                      itemCount:
                                          carouselSlides
                                              .length,
                                      onPageChanged:
                                          (index) {
                                        setState(() {
                                          slideIndex =
                                              index;
                                        });
                                      },
                                      itemBuilder:
                                          (
                                        context,
                                        index,
                                      ) {
                                        final slide =
                                            carouselSlides[
                                                index];

                                        return Stack(
                                          fit: StackFit
                                              .expand,
                                          children: [
                                            Image.network(
                                              slide[
                                                  'url']!,
                                              fit: BoxFit
                                                  .cover,
                                              errorBuilder:
                                                  (
                                                _,
                                                __,
                                                ___,
                                              ) {
                                                return Container(
                                                  color:
                                                      const Color(
                                                    0xFF1A2A5E,
                                                  ),
                                                );
                                              },
                                            ),

                                            // Gradient
                                            Container(
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
                                                    Color(
                                                      0xB80A1232,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // Text
                                            Positioned(
                                              left: 16,
                                              right: 16,
                                              bottom: 12,
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    slide[
                                                        'label']!,
                                                    style:
                                                        AppTypography
                                                            .heading(
                                                      17,
                                                    ).copyWith(
                                                      color:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        2,
                                                  ),
                                                  Text(
                                                    slide[
                                                        'sub']!,
                                                    style:
                                                        AppTypography
                                                            .body(
                                                      12,
                                                      color:
                                                          Colors.white.withValues(
                                                        alpha:
                                                            0.65,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // CEAT badge
                                            Positioned(
                                              top: 12,
                                              right: 12,
                                              child:
                                                  Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal:
                                                      8,
                                                  vertical:
                                                      4,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      const Color(
                                                    0xFFF5822D,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    4,
                                                  ),
                                                ),
                                                child:
                                                    const Text(
                                                  'CEAT',
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize:
                                                        11,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    letterSpacing:
                                                        0.8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    // Dots
                                    Positioned(
                                      bottom: 12,
                                      right: 16,
                                      child:
                                          Row(
                                        children:
                                            List.generate(
                                          carouselSlides
                                              .length,
                                          (index) {
                                            final active =
                                                index ==
                                                    slideIndex;

                                            return GestureDetector(
                                              onTap:
                                                  () =>
                                                      _goToSlide(
                                                index,
                                              ),
                                              child:
                                                  AnimatedContainer(
                                                duration:
                                                    const Duration(
                                                  milliseconds:
                                                      200,
                                                ),
                                                margin:
                                                    const EdgeInsets
                                                        .only(
                                                  left:
                                                      6,
                                                ),
                                                width:
                                                    active
                                                        ? 16
                                                        : 6,
                                                height:
                                                    6,
                                                decoration:
                                                    BoxDecoration(
                                                  color: active
                                                      ? const Color(
                                                          0xFFF5822D,
                                                        )
                                                      : Colors
                                                          .white
                                                          .withValues(
                                                          alpha:
                                                              0.5,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ==================================================
                          // PRODUCT CATEGORIES
                          // ==================================================

                          _sectionHeader(
                            title:
                                'PRODUCT CATEGORIES',
                            action: 'See all',
                            onAction: () {
                              state.setTab(1);
                            },
                          ),
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 20,
  ),
  child: _catalogueLoading
      ? const SizedBox(
          height: 96,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF203F99),
              ),
            ),
          ),
        )
      : _catalogueError != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: TextButton.icon(
                  onPressed: _loadCatalogue,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Failed to load categories. Tap to retry.'),
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _homeCategories.take(6).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 96,
              ),
              itemBuilder: (context, index) {
                final cat = _homeCategories[index];
                final catId = cat['id']?.toString().isNotEmpty == true
                    ? cat['id'].toString()
                    : cat['slug']?.toString() ?? '';
                final catName = cat['name']?.toString() ?? '';
                final imageUrl = cat['image']?.toString() ??
                    cat['icon_url']?.toString() ??
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl.isNotEmpty)
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1A2A5E),
                            ),
                          )
                        else
                          Container(
                            color: const Color(0xFF1A2A5E),
                            child: const Icon(
                              Icons.category_outlined,
                              color: Colors.white38,
                            ),
                          ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC203F99),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 6,
                          right: 6,
                          child: Text(
                            catName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
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

                          // ==================================================
                          // FEATURED PRODUCTS
                          // ==================================================

                          _sectionHeader(
                            title:
                                'FEATURED PRODUCTS',
                            action: '', // REMOVED
                            onAction: null,
                          ),

                          SizedBox(
                            height: 200,
                            child: _catalogueLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF203F99),
                                      ),
                                    ),
                                  )
                                : _catalogueError != null
                                    ? Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Unable to load featured products',
                                              style: AppTypography.body(13,
                                                  color: const Color(0xFF6B7280)),
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton.icon(
                                              onPressed: _loadCatalogue,
                                              icon: const Icon(Icons.refresh,
                                                  size: 16),
                                              label: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : featured.isEmpty
                                        ? Center(
                                            child: Text(
                                              'No featured products currently available.',
                                              style: AppTypography.body(13,
                                                  color: const Color(0xFF9CA3AF)),
                                            ),
                                          )
                                        : ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            itemCount: featured.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 16),
                                            itemBuilder: (context, index) {
                                              return ProductCard(
                                                product: featured[index],
                                              );
                                            },
                                          ),
                          ),

                          // ==================================================
                          // QUICK ACTIONS
                          // ==================================================

                          Padding(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              32,
                              20,
                              0,
                            ),
                            child: Text(
                              state.tr('sec_quick_actions'),
                              style:
                                  AppTypography
                                      .heading(
                                21,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 580;
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: isWide ? 4 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 72,
                                  children: [
                                    _quickAction(
                                      context,
                                      '📍',
                                      state.tr('qa_find_dealer'),
                                      'dealer-support',
                                      const Color(0xFF203F99),
                                    ),
                                    _quickAction(
                                      context,
                                      '📄',
                                      state.tr('qa_support_library'),
                                      'support',
                                      const Color(0xFF2D52C4),
                                    ),
                                    _quickAction(
                                      context,
                                      '💬',
                                      state.tr('qa_submit_feedback'),
                                      'voc-feedback',
                                      const Color(0xFFF5822D),
                                    ),
                                    _quickAction(
                                      context,
                                      '🔖',
                                      state.tr('qa_my_bookmarks'),
                                      'bookmarks',
                                      const Color(0xFF333333),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // ==================================================
                          // SUPPORT RESOURCES
                          // ==================================================

                          Container(
                            margin:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              32,
                              20,
                              0,
                            ),
                            padding:
                                const EdgeInsets.all(
                              20,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF203F99,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  state.tr('sec_support_resources'),
                                  style:
                                      AppTypography
                                          .heading(
                                    21,
                                  ).copyWith(
                                    color:
                                        Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final isWide = constraints.maxWidth > 580;
                                    return GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: isWide ? 4 : 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent: 58,
                                      children: [
                                        _resource(
                                          context,
                                          'FAQ',
                                          'faq',
                                        ),
                                        _resource(
                                          context,
                                          'Contact Support',
                                          'contact-support',
                                        ),
                                        _resource(
                                          context,
                                          'Testimonials',
                                          'testimonials',
                                        ),
                                        _resource(
                                          context,
                                          'Product Updates',
                                          'product-updates',
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration:
            BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.12,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        28,
        20,
        16,
      ),
      child: Row(
        children: [
          Text(
            title,
            style:
                AppTypography.heading(21),
          ),

          const Spacer(),

          if (action.isNotEmpty)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style:
                    AppTypography.body(
                  12,
                  color:
                      AppColors.orange,
                  weight:
                      FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION
  // ============================================================

  Widget _quickAction(
    BuildContext context,
    String icon,
    String label,
    String screen,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        _navigate(context, screen);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            16,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUPPORT RESOURCE
  // ============================================================

  Widget _resource(
    BuildContext context,
    String label,
    String screen,
  ) {
    return GestureDetector(
      onTap: () {
        _navigate(context, screen);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            height: 1.18,
          ),
        ),
      ),
    );
  }

}