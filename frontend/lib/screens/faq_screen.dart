import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/faq_item.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'contact_support_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<FAQItem> faqs = [];
  bool isLoading = true;
  String? errorMessage;

  final List<String> categories = const [
    'All',
    'Product',
    'Technical',
    'Warranty',
    'Applications',
    'Purchasing',
  ];

  String selectedCategory = 'All';
  String query = '';
  String? openId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFaqs();
    });
  }

  Future<void> _loadFaqs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final repo = context.read<AppState>().contentRepository;
      final fetched = await repo.getFaqs(pageSize: 100);
      if (mounted) {
        setState(() {
          faqs = fetched;
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = faqs.where((faq) {
      final matchesCategory =
          selectedCategory == 'All' ||
          faq.category == selectedCategory;

      final matchesQuery =
          query.isEmpty ||
          faq.question
              .toLowerCase()
              .contains(query.toLowerCase());

      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,

        title: Text(
          'FAQ',
          style: AppTypography.heading(
            24,
            color: Colors.white,
          ),
        ),
      ),

      body: Column(
        children: [

          // ======================================================
          // SEARCH + CATEGORY HEADER
          // ======================================================

          Container(
            color: AppColors.blue,
            child: Column(
              children: [

                // ------------------------------------------------
                // SEARCH
                // ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12,
                  ),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.white70,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                query = value;
                              });
                            },

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),

                            decoration:
                                const InputDecoration(
                              hintText:
                                  'Search questions…',
                              hintStyle: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),

                        if (query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();

                              setState(() {
                                query = '';
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------------
                // CATEGORY FILTER
                // ------------------------------------------------

                SizedBox(
                  height: 52,

                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    scrollDirection:
                        Axis.horizontal,

                    itemCount: categories.length,

                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),

                    itemBuilder: (_, index) {
                      final category =
                          categories[index];

                      final selected =
                          selectedCategory ==
                              category;

                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  category;
                              openId = null;
                            });
                          },

                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),

                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.orange
                                  : Colors.white
                                      .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Text(
                              category,
                              style: AppTypography.body(
                                11,
                                color: Colors.white,
                                weight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Orange accent
                Container(
                  height: 2,
                  color: AppColors.orange,
                ),
              ],
            ),
          ),

          // ======================================================
          // FAQ LIST
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
                                onPressed: _loadFaqs,
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
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          24,
                        ),
                        children: [
                          if (filtered.isEmpty)
                            _emptyState()
                          else
                            ...filtered.map(
                              (faq) => _faqCard(
                                context,
                                faq,
                              ),
                            ),
                          const SizedBox(height: 8),

                          // ==================================================
                          // CONTACT SUPPORT CTA
                          // ==================================================

                          _supportCTA(context),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // FAQ CARD
  // ==============================================================

  Widget _faqCard(
    BuildContext context,
    FAQItem faq,
  ) {
    final isOpen = openId == faq.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [

          // ------------------------------------------------------
          // QUESTION
          // ------------------------------------------------------

          InkWell(
            onTap: () {
              setState(() {
                openId = isOpen ? null : faq.id;
              });
            },

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        // Category
                        Text(
                          faq.category
                              .toString()
                              .toUpperCase(),

                          style: AppTypography.body(
                            9,
                            color: AppColors.orange,
                            weight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Question
                        Text(
                          faq.question,
                          style: AppTypography.body(
                            13,
                            weight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Expand button
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),

                    child: Container(
                      width: 28,
                      height: 28,

                      decoration: BoxDecoration(
                        color: isOpen
                            ? AppColors.blue
                            : AppColors.bg,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: isOpen
                            ? Colors.white
                            : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // ANSWER
          // ------------------------------------------------------

          AnimatedCrossFade(
            duration:
                const Duration(milliseconds: 180),

            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            firstChild:
                const SizedBox.shrink(),

            secondChild: Container(
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                17,
              ),

              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),

              child: Text(
                faq.answer,
                style: AppTypography.body(
                  12,
                  color: AppColors.body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 55,
      ),

      child: Column(
        children: [

          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.search_off,
              color: AppColors.blue,
              size: 25,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No questions found',
            style: AppTypography.body(
              13,
              weight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Try another search or category.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              11,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CONTACT SUPPORT CTA
  // ==============================================================

  Widget _supportCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Still have questions?',
            style: AppTypography.body(
              14,
              color: Colors.white,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Our technical team is available to help.',
            style: AppTypography.body(
              11,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 42,

            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ContactSupportScreen(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.orange,
                foregroundColor:
                    Colors.white,
                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(11),
                ),
              ),

              child: const Text(
                'CONTACT SUPPORT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}