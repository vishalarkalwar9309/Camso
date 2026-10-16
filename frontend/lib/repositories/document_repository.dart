import 'dart:async';
import '../core/api/api_client.dart';
import '../data/mock_data.dart' as mock;
import '../models/app_role.dart';
import '../models/document.dart';

/// Exception thrown when a document operation fails.
class DocumentException implements Exception {
  final String message;
  final int statusCode;
  final bool isNetworkError;

  const DocumentException(this.message, {this.statusCode = 500, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Metadata returned by the backend authorized download flow.
class DocumentDownloadInfo {
  final String documentId;
  final String downloadUrl;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;

  const DocumentDownloadInfo({
    required this.documentId,
    required this.downloadUrl,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
  });
}

/// Document Library Data Access Repository.
///
/// Backend endpoints:
/// - GET    /api/v1/documents
/// - GET    /api/v1/documents/:id
/// - GET    /api/v1/documents/:id/download
/// - POST   /api/v1/admin/documents
/// - PUT    /api/v1/admin/documents/:id
/// - DELETE /api/v1/admin/documents/:id
class DocumentRepository {
  final ApiClient _apiClient;

  DocumentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch documents with optional category, product, role access, and search query filters.
  Future<List<Document>> getDocuments({
    String? category,
    String? productId,
    AppRole? role,
    String? query,
    bool onlyAuthorized = false,
    int page = 1,
    int pageSize = 50,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (productId != null && productId.trim().isNotEmpty) {
      queryParams['product_id'] = productId.trim();
    }
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category;
    }
    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }

    final res = await _apiClient.get(
      '/documents',
      queryParams: queryParams,
    );

    if (res.isSuccess) {
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['items'] is List)
              ? (res.data as Map)['items'] as List
              : (res.data is Map && (res.data as Map)['documents'] is List)
                  ? (res.data as Map)['documents'] as List
                  : [];

      var list = items
          .map((item) => Document.fromJson(item as Map<String, dynamic>))
          .toList();

      if (onlyAuthorized && role != null) {
        list = list.where((d) => d.accessLevel.isAuthorized(role)).toList();
      }
      return list;
    }

    if (res.statusCode == 0) {
      throw DocumentException('Network connection failed. Could not load documents.',
          statusCode: 0, isNetworkError: true);
    }

    throw DocumentException(
      res.errorMessage ?? 'Failed to load documents (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Get document by ID.
  Future<Document> getDocumentById(String id) async {
    final res = await _apiClient.get('/documents/$id');

    if (res.isSuccess && res.data is Map) {
      return Document.fromJson(res.data as Map<String, dynamic>);
    }

    if (res.statusCode == 0) {
      throw DocumentException('Network connection failed. Could not load document.',
          statusCode: 0, isNetworkError: true);
    }

    throw DocumentException(
      res.errorMessage ?? 'Document not found or inaccessible (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Request authorization and get download metadata including signed URL.
  Future<DocumentDownloadInfo> getDownloadInfo(String id) async {
    final res = await _apiClient.get('/documents/$id/download');

    if (res.isSuccess) {
      if (res.data is Map) {
        final data = res.data as Map;
        final dlUrl = data['download_url']?.toString() ??
            data['url']?.toString() ??
            '${ApiClient.baseUrl}/documents/$id/download';
        final fileName = data['file_name']?.toString() ??
            data['filename']?.toString() ??
            'document_$id.pdf';
        final mimeType = data['mime_type']?.toString() ?? 'application/pdf';
        final sizeBytes = (data['file_size_bytes'] is num)
            ? (data['file_size_bytes'] as num).toInt()
            : 0;

        return DocumentDownloadInfo(
          documentId: id,
          downloadUrl: dlUrl,
          fileName: fileName,
          mimeType: mimeType,
          fileSizeBytes: sizeBytes,
        );
      }
      return DocumentDownloadInfo(
        documentId: id,
        downloadUrl: '${ApiClient.baseUrl}/documents/$id/download',
        fileName: 'document_$id.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 0,
      );
    }

    if (res.statusCode == 403) {
      throw const DocumentException(
        'Access restricted. Your account role is not authorized to download this document.',
        statusCode: 403,
      );
    }

    if (res.statusCode == 404) {
      throw const DocumentException(
        'Document not found or unpublished.',
        statusCode: 404,
      );
    }

    if (res.statusCode == 422) {
      throw DocumentException(
        res.errorMessage ?? 'Invalid document ID.',
        statusCode: 422,
      );
    }

    if (res.statusCode == 0) {
      throw const DocumentException(
        'Network connection failed. Could not download document.',
        statusCode: 0,
        isNetworkError: true,
      );
    }

    throw DocumentException(
      res.errorMessage ?? 'Download failed (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Request authorization and download a document (returns signed URL).
  Future<String> downloadDocument(String id) async {
    final info = await getDownloadInfo(id);
    return info.downloadUrl;
  }

  // --- Admin Methods ---

  static String _mapDocumentType(String rawType) {
    final lower = rawType.trim().toLowerCase();
    if (lower.contains('catalogue') || lower.contains('catalog')) return 'CATALOGUE';
    if (lower.contains('brochure')) return 'BROCHURE';
    if (lower.contains('manual')) return 'MANUAL';
    if (lower.contains('bulletin')) return 'BULLETIN';
    if (lower.contains('warranty')) return 'WARRANTY';
    if (lower.contains('video')) return 'VIDEO';
    return 'TECHNICAL_GUIDE';
  }

  Future<Document> addDocument(Document document) async {
    final body = <String, dynamic>{
      'title': document.title,
      'document_type': _mapDocumentType(document.type),
      'is_published': true,
      if (document.productId != null && document.productId!.isNotEmpty)
        'product_id': document.productId,
    };

    final res = await _apiClient.post('/admin/documents', body: body);
    if (!res.isSuccess) {
      throw DocumentException(res.errorMessage ?? 'Failed to create document.',
          statusCode: res.statusCode);
    }

    if (res.data != null && res.data is Map) {
      return Document.fromJson(Map<String, dynamic>.from(res.data as Map));
    }
    return document;
  }

  Future<void> updateDocument(Document document) async {
    final body = <String, dynamic>{
      'title': document.title,
      'document_type': _mapDocumentType(document.type),
      'is_published': true,
      if (document.productId != null && document.productId!.isNotEmpty)
        'product_id': document.productId,
    };

    final res = await _apiClient.patch('/admin/documents/${document.id}', body: body);
    if (!res.isSuccess) {
      throw DocumentException(res.errorMessage ?? 'Failed to update document.',
          statusCode: res.statusCode);
    }
  }

  Future<void> deleteDocument(String id) async {
    // Backend documents module does not register DELETE /api/v1/admin/documents/:id.
    // Consistent with the backend design, documents are unpublished via PATCH is_published: false.
    final res = await _apiClient.patch(
      '/admin/documents/$id',
      body: {'is_published': false},
    );
    if (!res.isSuccess) {
      throw DocumentException(res.errorMessage ?? 'Failed to unpublish document.',
          statusCode: res.statusCode);
    }
  }

  /// Explicit isolated demo documents for offline unit testing.
  List<Document> getDemoDocuments() {
    return List<Document>.from(mock.documents);
  }
}

