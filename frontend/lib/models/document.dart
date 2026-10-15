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
  final bool isOfflineDownloadable;

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
    this.accessLevel = DocumentAccessLevel.public,
    this.downloadUrl,
    this.isOfflineDownloadable = true,
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
    DocumentAccessLevel? accessLevel,
    String? downloadUrl,
    bool? isOfflineDownloadable,
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
      accessLevel: accessLevel ?? this.accessLevel,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isOfflineDownloadable:
          isOfflineDownloadable ?? this.isOfflineDownloadable,
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    final sizeBytes = json['file_size_bytes'] ?? json['size_bytes'] ?? 0;
    String sizeStr = '1.2 MB';
    if (sizeBytes is num && sizeBytes > 0) {
      if (sizeBytes >= 1024 * 1024) {
        sizeStr = '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      } else {
        sizeStr = '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
      }
    } else if (json['fileSize'] != null) {
      sizeStr = json['fileSize'].toString();
    }

    String fmt = 'PDF';
    final mime = json['mime_type']?.toString().toLowerCase() ?? '';
    if (mime.contains('pdf')) {
      fmt = 'PDF';
    } else if (mime.contains('image')) {
      fmt = 'IMG';
    } else if (mime.contains('video')) {
      fmt = 'VIDEO';
    } else if (json['format'] != null) {
      fmt = json['format'].toString();
    }

    return Document(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Datasheet',
      category: json['category']?.toString() ?? 'General',
      fileSize: sizeStr,
      format: fmt,
      date: json['created_at']?.toString().split('T').first ?? json['date']?.toString() ?? '2026',
      version: json['version']?.toString() ?? '1.0',
      description: json['description']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? json['productId']?.toString(),
      pages: (json['pages'] is num) ? (json['pages'] as num).toInt() : 4,
      language: json['language']?.toString() ?? 'EN',
      isDownloaded: json['isDownloaded'] == true,
      accessLevel: DocumentAccessLevel.fromString(json['access_level']?.toString() ?? json['accessLevel']?.toString()),
      downloadUrl: json['url']?.toString() ?? json['downloadUrl']?.toString() ?? (json['id'] != null ? '${ApiClient.baseUrl}/documents/${json['id']}/download' : null),
      isOfflineDownloadable: json['isOfflineDownloadable'] != false,
    );
  }
}