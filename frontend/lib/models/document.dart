import '../core/api/api_client.dart';
import '../models/app_role.dart';

/// Access level required to view and download a document.
enum DocumentAccessLevel {
  public,
  dealer,
  distributor,
  employee,
  oem,
  admin;

  String get label {
    switch (this) {
      case DocumentAccessLevel.public:
        return 'Public';
      case DocumentAccessLevel.dealer:
        return 'Dealer Only';
      case DocumentAccessLevel.distributor:
        return 'Distributor Only';
      case DocumentAccessLevel.employee:
        return 'Employee Only';
      case DocumentAccessLevel.oem:
        return 'OEM Partner Only';
      case DocumentAccessLevel.admin:
        return 'Admin Only';
    }
  }

  /// Check whether an [AppRole] is authorized to access this document level.
  bool isAuthorized(AppRole role) {
    if (this == DocumentAccessLevel.public) return true;
    if (role == AppRole.admin) return true;

    switch (this) {
      case DocumentAccessLevel.dealer:
        return role == AppRole.dealer;
      case DocumentAccessLevel.distributor:
        return role == AppRole.distributor;
      case DocumentAccessLevel.employee:
        return role == AppRole.employee;
      case DocumentAccessLevel.oem:
        return role == AppRole.oemPartner;
      case DocumentAccessLevel.admin:
        return role == AppRole.admin;
      case DocumentAccessLevel.public:
        return true;
    }
  }

  static DocumentAccessLevel fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'dealer':
        return DocumentAccessLevel.dealer;
      case 'distributor':
        return DocumentAccessLevel.distributor;
      case 'employee':
      case 'internal':
        return DocumentAccessLevel.employee;
      case 'oem':
      case 'oem_partner':
        return DocumentAccessLevel.oem;
      case 'admin':
        return DocumentAccessLevel.admin;
      case 'public':
      default:
        return DocumentAccessLevel.public;
    }
  }
}

class Document {
  final String id;
  final String title;
  final String type;
  final String category;
  final String fileSize;
  final String format;
  final String date;
  final String version;
  final String description;
  final String? productId;
  final int pages;
  final String language;
  final bool isDownloaded;
  final DocumentAccessLevel accessLevel;
  final String? downloadUrl;
  final bool hasFile;
  final bool isOfflineDownloadable;
  final String? filename;
  final int? fileSizeBytes;

  const Document({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.fileSize,
    required this.format,
    required this.date,
    required this.version,
    required this.description,
    required this.productId,
    required this.pages,
    required this.language,
    required this.isDownloaded,
    this.hasFile = true,
    this.accessLevel = DocumentAccessLevel.public,
    this.downloadUrl,
    this.isOfflineDownloadable = true,
    this.filename,
    this.fileSizeBytes,
  });

  bool get isPublic => accessLevel == DocumentAccessLevel.public;

  Document copyWith({
    String? id,
    String? title,
    String? type,
    String? category,
    String? fileSize,
    String? format,
    String? date,
    String? version,
    String? description,
    String? productId,
    int? pages,
    String? language,
    bool? isDownloaded,
    bool? hasFile,
    DocumentAccessLevel? accessLevel,
    String? downloadUrl,
    bool? isOfflineDownloadable,
    String? filename,
    int? fileSizeBytes,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      date: date ?? this.date,
      version: version ?? this.version,
      description: description ?? this.description,
      productId: productId ?? this.productId,
      pages: pages ?? this.pages,
      language: language ?? this.language,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      hasFile: hasFile ?? this.hasFile,
      accessLevel: accessLevel ?? this.accessLevel,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isOfflineDownloadable:
          isOfflineDownloadable ?? this.isOfflineDownloadable,
      filename: filename ?? this.filename,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    final sizeBytes = json['file_size_bytes'] ?? json['size_bytes'];
    final bool hasFile = json['has_file'] == true ||
        (json['files'] is List && (json['files'] as List).isNotEmpty) ||
        (sizeBytes is num && sizeBytes > 0);

    String sizeStr = 'File not attached';
    if (sizeBytes is num && sizeBytes > 0) {
      if (sizeBytes >= 1024 * 1024) {
        sizeStr = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        sizeStr = '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
      }
    } else if (json['fileSize'] != null && json['fileSize'].toString().isNotEmpty) {
      sizeStr = json['fileSize'].toString();
    } else if (!hasFile) {
      sizeStr = 'File not attached';
    }

    String fmt = 'PDF';
    final mime = json['mime_type']?.toString().toLowerCase() ?? '';
    if (mime.contains('pdf')) {
      fmt = 'PDF';
    } else if (mime.contains('image')) {
      fmt = 'IMG';
    } else if (mime.contains('video')) {
      fmt = 'VIDEO';
    } else if (json['format'] != null && json['format'].toString().isNotEmpty) {
      fmt = json['format'].toString();
    }

    final int pagesCount = (json['pages'] is num)
        ? (json['pages'] as num).toInt()
        : (hasFile ? 4 : 0);

    String? dlUrl = json['url']?.toString() ?? json['downloadUrl']?.toString();
    if (dlUrl == null && hasFile && json['id'] != null) {
      dlUrl = '${ApiClient.baseUrl}/documents/${json['id']}/download';
    }

    final String? parsedFilename = json['filename']?.toString() ??
        json['file_name']?.toString() ??
        ((json['files'] is List &&
                (json['files'] as List).isNotEmpty &&
                (json['files'] as List).first is Map)
            ? ((json['files'] as List).first['filename']?.toString() ??
               (json['files'] as List).first['file_name']?.toString())
            : null);

    return Document(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Document',
      type: json['type']?.toString() ?? json['document_type']?.toString() ?? 'Datasheet',
      category: json['category']?.toString() ?? 'general',
      fileSize: sizeStr,
      format: fmt,
      date: json['created_at']?.toString().split('T').first ?? json['date']?.toString() ?? '2026',
      version: json['version']?.toString() ?? (hasFile ? '1.0' : '—'),
      description: json['description']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['productId']?.toString(),
      pages: pagesCount,
      language: json['language']?.toString() ?? 'EN',
      isDownloaded: json['isDownloaded'] == true,
      hasFile: hasFile,
      accessLevel: DocumentAccessLevel.fromString(json['access_level']?.toString() ?? json['accessLevel']?.toString()),
      downloadUrl: dlUrl,
      isOfflineDownloadable: json['isOfflineDownloadable'] != false,
      filename: parsedFilename,
      fileSizeBytes: (sizeBytes is num) ? sizeBytes.toInt() : null,
    );
  }
}