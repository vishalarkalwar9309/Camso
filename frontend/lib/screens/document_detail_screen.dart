import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/auth/bookmark_guard.dart';
import '../data/mock_data.dart';
import '../models/document.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'product_detail_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String? documentId;
  final String title;

  const DocumentDetailScreen({
    super.key,
    this.documentId,
    this.title = 'CAMSO Product Catalog 2024–25',
  });

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool downloaded = false;
  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final doc = _findDocument(state);
    final isAuthorized = doc == null || state.permissions.canViewDocument(doc);
    final relatedProduct = _findRelatedProduct(doc?.productId);

    final isBookmarked = doc != null && state.isBookmarked(doc.id);
    final category = doc?.category ?? 'brochures';
    final color = _categoryColor(category);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'DOCUMENT',
          style: AppTypography.heading(22, color: Colors.white),
        ),
        actions: [
          if (doc != null)
            IconButton(
              tooltip: 'Bookmark',
              onPressed: () => BookmarkGuard.toggle(context, doc.id, itemName: 'document'),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Color Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              doc?.format ?? 'PDF',
                              style: TextStyle(
                                color: color,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Barlow Condensed',
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (doc != null && !doc.isPublic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAuthorized
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    doc.accessLevel.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doc?.title ?? widget.title,
                        style: AppTypography.heading(20, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _headerChip(doc?.type ?? 'Technical Resource'),
                          _headerChip('v${doc?.version ?? '1.0'}'),
                          _headerChip('${doc?.pages ?? 12} pages'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Document Information or Access Restriction Banner
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isAuthorized) ...[
                        _buildAccessGate(context, state, doc),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        doc?.description ??
                            'This document provides product and technical information for CAMSO construction tires and tracks.',
                        style: AppTypography.body(12,
                            color: const Color(0xFF555555)),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisExtent: 60,
                        children: [
                          _metaBox('FILE SIZE', doc?.fileSize ?? '3.5 MB'),
                          _metaBox('FORMAT', doc?.format ?? 'PDF'),
                          _metaBox('DATE', _formatDate(doc?.date)),
                          _metaBox('LANGUAGES', doc?.language ?? 'EN / FR / DE'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: !isAuthorized
                              ? () => _promptUnauthorized(context, doc)
                              : (downloading || downloaded || doc == null ? null : () => _handleDownload(doc)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isAuthorized
                                ? const Color(0xFF9CA3AF)
                                : (downloaded
                                    ? AppColors.lightBlue
                                    : AppColors.blue),
                            foregroundColor: downloaded
                                ? AppColors.blue
                                : Colors.white,
                            disabledBackgroundColor: downloaded
                                ? AppColors.lightBlue
                                : AppColors.blue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _downloadButtonContent(isAuthorized),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Related Product Link
          if (relatedProduct != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.blue),
                  ),
                  title: Text(
                    relatedProduct.name,
                    style: AppTypography.body(13, weight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'PID: ${relatedProduct.pid} · ${relatedProduct.size}',
                    style: AppTypography.body(11, color: AppColors.muted),
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: relatedProduct),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccessGate(
      BuildContext context, AppState state, Document doc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFDC2626), size: 18),
              const SizedBox(width: 8),
              Text(
                'RESTRICTED DOCUMENT',
                style: AppTypography.body(12,
                    color: const Color(0xFFDC2626), weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This document requires ${doc.accessLevel.label} authorization. You are currently using the app as ${state.roleLabel}.',
            style: AppTypography.body(11, color: const Color(0xFF991B1B)),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.login, size: 15),
            label: const Text('Sign in with authorized account',
                style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDownload(Document doc) async {
    final state = context.read<AppState>();
    setState(() => downloading = true);

    try {
      final downloadUrl = await state.documentRepository.downloadDocument(doc.id);
      if (!mounted) return;

      bool opened = false;
      final uri = Uri.tryParse(downloadUrl);
      if (uri != null && await canLaunchUrl(uri)) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!mounted) return;
      if (!opened) {
        setState(() {
          downloading = false;
          downloaded = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              downloadUrl.isNotEmpty
                  ? 'Document retrieved, but could not open viewer for URL: $downloadUrl'
                  : 'Document retrieved, but could not launch external viewer.',
            ),
            backgroundColor: const Color(0xFFF59E0B),
          ),
        );
        return;
      }

      setState(() {
        downloading = false;
        downloaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authorized document opened in external viewer.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  void _promptUnauthorized(BuildContext context, Document doc) {
    showDialog<void>(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Access Restricted'),

        content: Text(
          'This document requires ${doc.accessLevel.label} permissions. Please sign in with an authorized account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dContext);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _downloadButtonContent(bool isAuthorized) {
    if (!isAuthorized) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 16),
          SizedBox(width: 8),
          Text('SIGN IN TO ACCESS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      );
    }
    if (downloading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 9),
          Text('DOWNLOADING...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
    }
    if (downloaded) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, size: 17),
          SizedBox(width: 7),
          Text('DOWNLOADED',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.download_outlined, size: 17),
        SizedBox(width: 7),
        Text('DOWNLOAD DOCUMENT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _headerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _metaBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.body(8,
                color: AppColors.muted, weight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(10, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Document? _findDocument(AppState state) {
    final requestedId = widget.documentId;
    if (requestedId != null) {
      try {
        return state.documentItems.firstWhere((d) => d.id == requestedId);
      } catch (_) {}
      try {
        return documents.firstWhere((d) => d.id == requestedId);
      } catch (_) {}
    }
    try {
      return state.documentItems.firstWhere((d) => d.title == widget.title);
    } catch (_) {}
    return null;
  }

  Product? _findRelatedProduct(String? productId) {
    if (productId == null) return null;
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final date = DateTime.parse(raw);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return raw;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'brochures':
        return AppColors.blue;
      case 'manuals':
        return AppColors.orange;
      case 'maintenance':
        return const Color(0xFF10B981);
      case 'technical':
        return const Color(0xFFEF4444);
      case 'warranty':
        return const Color(0xFF6B7280);
      default:
        return AppColors.blue;
    }
  }
}