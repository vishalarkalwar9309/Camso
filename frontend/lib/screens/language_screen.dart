import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../data/mock_data.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List<Map<String, String>> _languageList = List<Map<String, String>>.from(languages);
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLanguages());
  }

  Future<void> _fetchLanguages() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final repo = context.read<AppState>().contentRepository;
      final results = await repo.getLanguages();
      if (mounted && results.isNotEmpty) {
        final mapped = results.map<Map<String, String>>((item) {
          return {
            'code': item['code']?.toString() ?? '',
            'name': item['name']?.toString() ?? '',
            'nativeName': item['native_name']?.toString() ?? item['name']?.toString() ?? '',
            'flag': item['flag']?.toString() ?? '🌐',
          };
        }).toList();
        setState(() {
          _languageList = mapped;
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
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: Text(
          'LANGUAGE',
          style: AppTypography.heading(24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.orange),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFE4E7EF),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(
                _languageList.length,
                (index) {
                  final language = _languageList[index];
                  final isSelected =
                      state.language == language['code'];

                  return Material(
                    color: isSelected
                        ? const Color(0xFFEEF1FA)
                        : Colors.white,
                    child: InkWell(
                      onTap: () {
                        state.setLanguage(language['code']!);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Language changed to ${language['name']}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: index < _languageList.length - 1
                              ? const Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFF2F4F8),
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              language['flag']!,
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    language['name']!,
                                    style: AppTypography.body(
                                      13,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    language['native']!,
                                    style: AppTypography.body(
                                      10,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'More languages coming soon.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              11,
              color: AppColors.muted,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontSize: 13,
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