import 'dart:async';
import '../core/api/api_client.dart';
import '../models/document.dart';
import '../models/faq_item.dart';
import '../models/testimonial.dart';

/// Exception thrown when a content or portal API request fails.
class ContentException implements Exception {
  final String message;
  final int statusCode;
  final bool isNetworkError;

  const ContentException(this.message, {this.statusCode = 500, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Content, Business Portal & Customer Engagement Data Access Repository.
///
/// Implements backend endpoints:
/// - GET  /api/v1/faqs
/// - GET  /api/v1/testimonials
/// - GET  /api/v1/testimonials/:id
/// - GET  /api/v1/dealers/locator
/// - POST /api/v1/feedback
/// - GET  /api/v1/business/organization
/// - GET  /api/v1/business/dealer/portal
/// - GET  /api/v1/business/distributor/portal
/// - GET  /api/v1/business/oem/portal
/// - GET  /api/v1/business/oem/documents
/// - GET  /api/v1/admin/analytics/catalogue
/// - GET  /api/v1/admin/analytics/content
/// - GET  /api/v1/content/:key
class ContentRepository {
  final ApiClient _apiClient;

  ContentRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // =========================================================================
  // FAQs
  // =========================================================================

  Future<List<FAQItem>> getFaqs({
    String? category,
    String lang = 'en',
    int page = 1,
    int pageSize = 50,
  }) async {
    final query = <String, String>{
      'lang': lang,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      query['category'] = category;
    }

    final res = await _apiClient.get('/faqs', queryParams: query);

    if (res.isSuccess) {
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['items'] is List)
              ? (res.data as Map)['items'] as List
              : (res.data is Map && (res.data as Map)['faqs'] is List)
                  ? (res.data as Map)['faqs'] as List
                  : [];

      return items
          .map((item) => FAQItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (res.statusCode == 0) {
      throw const ContentException('Network connection failed. Could not load FAQs.',
          statusCode: 0, isNetworkError: true);
    }

    throw ContentException(
      res.errorMessage ?? 'Failed to load FAQs (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  // =========================================================================
  // Testimonials
  // =========================================================================

  Future<List<Testimonial>> getTestimonials({
    String? storyType,
    String? productId,
    int page = 1,
    int pageSize = 50,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (storyType != null && storyType.isNotEmpty && storyType.toLowerCase() != 'all') {
      query['story_type'] = storyType;
    }
    if (productId != null && productId.isNotEmpty) {
      query['product_id'] = productId;
    }

    final res = await _apiClient.get('/testimonials', queryParams: query);

    if (res.isSuccess) {
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['items'] is List)
              ? (res.data as Map)['items'] as List
              : (res.data is Map && (res.data as Map)['testimonials'] is List)
                  ? (res.data as Map)['testimonials'] as List
                  : [];

      return items
          .map((item) => Testimonial.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (res.statusCode == 0) {
      throw const ContentException('Network connection failed. Could not load testimonials.',
          statusCode: 0, isNetworkError: true);
    }

    throw ContentException(
      res.errorMessage ?? 'Failed to load testimonials (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  Future<Testimonial> getTestimonialById(String id) async {
    final res = await _apiClient.get('/testimonials/$id');

    if (res.isSuccess && res.data is Map) {
      return Testimonial.fromJson(res.data as Map<String, dynamic>);
    }

    if (res.statusCode == 0) {
      throw const ContentException('Network connection failed. Could not load testimonial.',
          statusCode: 0, isNetworkError: true);
    }

    throw ContentException(
      res.errorMessage ?? 'Testimonial not found (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  // =========================================================================
  // Dealers Locator
  // =========================================================================

  Future<List<Map<String, dynamic>>> getDealersLocator({
    double? lat,
    double? lng,
    double radiusKm = 1000,
    String? type,
    String? queryText,
  }) async {
    final query = <String, String>{};
    if (lat != null && lng != null) {
      query['lat'] = lat.toString();
      query['lng'] = lng.toString();
      query['radiusKm'] = radiusKm.toString();
    }
    if (type != null && type.isNotEmpty && type.toLowerCase() != 'all') {
      query['type'] = type.toUpperCase();
    }
    if (queryText != null && queryText.trim().isNotEmpty) {
      query['query'] = queryText.trim();
    }

    final res = await _apiClient.get('/dealers/locator', queryParams: query);

    if (res.isSuccess && res.data is List) {
      return List<Map<String, dynamic>>.from(
        (res.data as List).whereType<Map<String, dynamic>>(),
      );
    }

    if (res.statusCode == 0) {
      throw const ContentException('Network connection failed. Could not locate dealers.',
          statusCode: 0, isNetworkError: true);
    }

    throw ContentException(
      res.errorMessage ?? 'Dealer locator search failed (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  // =========================================================================
  // Feedback
  // =========================================================================

  Future<Map<String, dynamic>> submitFeedback({
    required String bucket,
    required int rating,
    String? comment,
    String? productId,
  }) async {
    final body = <String, dynamic>{
      'bucket': bucket.toUpperCase(),
      'rating': rating,
    };
    if (comment != null && comment.trim().isNotEmpty) {
      body['comment'] = comment.trim();
    }
    if (productId != null && productId.isNotEmpty) {
      body['product_id'] = productId;
    }

    final res = await _apiClient.post('/feedback', body: body);

    if (res.isSuccess) {
      return res.data is Map ? Map<String, dynamic>.from(res.data as Map) : {'success': true};
    }

    if (res.statusCode == 401) {
      throw const ContentException('Authentication required. Please sign in to submit feedback.',
          statusCode: 401);
    }

    if (res.statusCode == 0) {
      throw const ContentException('Network connection failed. Could not submit feedback.',
          statusCode: 0, isNetworkError: true);
    }

    throw ContentException(
      res.errorMessage ?? 'Failed to submit feedback (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  // =========================================================================
  // Business Portals
  // =========================================================================

  Future<Map<String, dynamic>> getBusinessOrganization() async {
    final res = await _apiClient.get('/business/organization');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to load organization (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<Map<String, dynamic>> getDealerPortal() async {
    final res = await _apiClient.get('/business/dealer/portal');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to access dealer portal (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<Map<String, dynamic>> getDistributorPortal() async {
    final res = await _apiClient.get('/business/distributor/portal');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to access distributor portal (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<Map<String, dynamic>> getOemPortal() async {
    final res = await _apiClient.get('/business/oem/portal');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to access OEM portal (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<List<Document>> getOemDocuments() async {
    final res = await _apiClient.get('/business/oem/documents');
    if (res.isSuccess && res.data is List) {
      return (res.data as List)
          .map((item) => Document.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ContentException(res.errorMessage ?? 'Failed to load OEM documents (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  // =========================================================================
  // Admin Analytics & Legal Content
  // =========================================================================

  Future<Map<String, dynamic>> getCatalogueAnalytics({int limit = 10}) async {
    final res = await _apiClient.get('/admin/analytics/catalogue', queryParams: {'limit': limit.toString()});
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to load catalogue analytics (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<Map<String, dynamic>> getContentAnalytics() async {
    final res = await _apiClient.get('/admin/analytics/content');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to load content analytics (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  Future<Map<String, dynamic>> getPublicContent(String key) async {
    final res = await _apiClient.get('/content/$key');
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(res.errorMessage ?? 'Failed to load content for $key (${res.statusCode}).',
        statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
  }

  // =========================================================================
  // Languages & Internationalization
  // =========================================================================

  Future<List<Map<String, dynamic>>> getLanguages() async {
    final res = await _apiClient.get('/languages');
    if (res.isSuccess && res.data is List) {
      return List<Map<String, dynamic>>.from(
        (res.data as List).whereType<Map<String, dynamic>>(),
      );
    }
    return [];
  }

  // =========================================================================
  // Business Registration & Admin Approvals
  // =========================================================================

  Future<Map<String, dynamic>> registerBusinessOrganization({
    required Map<String, dynamic> organization,
    required Map<String, dynamic> user,
  }) async {
    final res = await _apiClient.post('/business-auth/register', body: {
      'organization': organization,
      'user': user,
    });
    if (res.isSuccess && res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw ContentException(
      res.errorMessage ?? 'Business registration failed (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getAdminOrganizations({String? status}) async {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    final res = await _apiClient.get('/admin/organizations', queryParams: query);
    if (res.isSuccess && res.data is List) {
      return List<Map<String, dynamic>>.from(
        (res.data as List).whereType<Map<String, dynamic>>(),
      );
    }
    return [];
  }

  Future<void> updateOrganizationApproval({
    required String id,
    required String status,
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'approval_status': status,
      'status': status,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };
    final res = await _apiClient.patch('/admin/organizations/$id/status', body: body);
    if (!res.isSuccess) {
      throw ContentException(
        res.errorMessage ?? 'Failed to update organization approval status (${res.statusCode}).',
        statusCode: res.statusCode,
      );
    }
  }
}
