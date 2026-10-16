import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/bookmark_guard.dart';
import '../core/download/document_download_service.dart';
import '../models/document.dart';
import '../repositories/document_repository.dart';
import '../screens/document_detail_screen.dart';
import '../state/app_state.dart';

class DocumentCard extends StatefulWidget {
  final Document doc;

  const DocumentCard({
    super.key,
    required this.doc,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool downloaded = false;
  bool downloading = false;
  String? _savedFilePath;

  String get category => widget.doc.category;
  String get title => widget.doc.title;
  String get type => widget.doc.type;
  String get fileSize => widget.doc.fileSize;
  String get version => widget.doc.version;
  String get id => widget.doc.id;
  DocumentAccessLevel get accessLevel => widget.doc.accessLevel;

  static const Map<String, Color> categoryColors = {
    'brochures': Color(0xFF203F99),
    'manuals': Color(0xFFF5822D),
    'maintenance': Color(0xFF10B981),
    'technical': Color(0xFFEF4444),
    'warranty': Color(0xFF6B7280),
  };

  static const Map<String, String> categoryIcons = {
    'brochures': 'B',
    'manuals': 'M',
    'maintenance': 'G',
    'technical': 'T',
    'warranty': 'W',
  };

  @override
  void initState() {
    super.initState();
    downloaded = widget.doc.isDownloaded;
  }

  Future<void> handleDownload(bool isAuthorized) async {
    final appState = context.read<AppState>();
    if (downloading) return;

    if (!widget.doc.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This document record does not currently have a downloadable file attached.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    if (!isAuthorized || (!widget.doc.isPublic && !appState.loggedIn)) {
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Authentication required'),
            content: Text(
              widget.doc.isPublic
                  ? 'Please sign in to download offline documents.'
                  : 'This document requires ${accessLevel.label} authorization. Please sign in with an authorized account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Sign In'),
              ),
            ],
          );
        },
      );

      if (shouldSignIn == true && mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    setState(() => downloading = true);
    try {
      final info = await appState.documentRepository.getDownloadInfo(widget.doc.id);
      if (!mounted) return;

      final preferredName = widget.doc.filename != null && widget.doc.filename!.isNotEmpty
          ? widget.doc.filename!
          : (info.fileName.isNotEmpty ? info.fileName : '${title.replaceAll(' ', '_')}.pdf');

      final downloadService = DocumentDownloadService();
      final result = await downloadService.downloadAndSave(
        downloadUrl: info.downloadUrl,
        preferredFileName: preferredName,
      );

      if (!mounted) return;

      if (!result.isSuccess) {
        setState(() {
          downloading = false;
          downloaded = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Download failed.'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }

      setState(() {
        downloading = false;
        downloaded = true;
        _savedFilePath = result.filePath;
      });

      final displayMsg = result.isAccessibleDownloadsFolder
          ? 'Saved "${result.fileName}" to ${result.displayLocation}'
          : 'Saved "${result.fileName}"';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 7),
          content: Text(displayMsg),
          backgroundColor: const Color(0xFF10B981),
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () {
              downloadService.openFile(result.filePath!);
            },
          ),
        ),
      );
    } on DocumentException catch (e) {
      if (!mounted) return;
      setState(() => downloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFDC2626),
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAuthorized = appState.permissions.canViewDocument(widget.doc);

    final color = categoryColors[category] ?? const Color(0xFF203F99);
    final icon = categoryIcons[category] ?? 'D';
    final isBookmarked = appState.isBookmarked(id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DocumentDetailScreen(
                document: widget.doc,
                documentId: id,
                title: title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFE4E7EF),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  icon,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Barlow Condensed',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title and Meta Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: color,
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Access Level Tag
                        if (!widget.doc.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isAuthorized
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAuthorized ? Icons.lock_open : Icons.lock,
                                  size: 11,
                                  color: isAuthorized
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  accessLevel.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isAuthorized
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Text(
                          fileSize,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'Inter',
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          'v$version',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'Inter',
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Actions: Bookmark & Download
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _circleButton(
                    background: isBookmarked
                        ? const Color(0xFFEEF1FA)
                        : const Color(0xFFF2F4F8),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 15,
                      color: isBookmarked
                          ? const Color(0xFF203F99)
                          : const Color(0xFF9CA3AF),
                    ),
                    onTap: () {
                      BookmarkGuard.toggle(context, id, itemName: 'document');
                    },
                  ),
                  const SizedBox(width: 6),
                  _circleButton(
                    background: downloaded
                        ? const Color(0xFFEEF1FA)
                        : const Color(0xFFF2F4F8),
                    child: downloading
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF203F99),
                              ),
                            ),
                          )
                        : Icon(
                            downloaded ? Icons.check : Icons.download_outlined,
                            size: 15,
                            color: downloaded
                                ? const Color(0xFF203F99)
                                : const Color(0xFF6B7280),
                          ),
                    onTap: () {
                      if (downloaded && _savedFilePath != null) {
                        DocumentDownloadService().openFile(_savedFilePath!);
                      } else {
                        handleDownload(isAuthorized);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required Color background,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(child: child),
        ),
      ),
    );
  }
}