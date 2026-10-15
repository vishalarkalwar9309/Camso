import 'dart:async';
import '../core/api/api_client.dart';
import '../data/mock_data.dart' as mock;
import '../models/product.dart';

/// Exception thrown when a bookmark operation fails.
class BookmarkException implements Exception {
  final String message;
  final int statusCode;
  final bool isNetworkError;

  const BookmarkException(this.message, {this.statusCode = 500, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Bookmarks Data Access Repository.
///
/// Corresponds to documented backend endpoints:
/// - GET    /api/v1/bookmarks
/// - POST   /api/v1/bookmarks        { product_id }
/// - DELETE /api/v1/bookmarks/:id
/// - POST   /api/v1/bookmarks/sync   { guest_token }
class BookmarkRepository {
  final ApiClient _apiClient;

  BookmarkRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final Set<String> _bookmarkedIds = <String>{};

  Set<String> get currentIds => Set.unmodifiable(_bookmarkedIds);

  /// Fetch IDs of bookmarked products for user or guest device.
  Future<Set<String>> getBookmarks({bool isAuthenticated = false, String? deviceId}) async {
    final query = <String, String>{};
    if (deviceId != null && deviceId.isNotEmpty) {
      query['device_id'] = deviceId;
    }

    final res = await _apiClient.get(
      '/bookmarks',
      queryParams: query.isNotEmpty ? query : null,
    );

    if (res.isSuccess) {
      _bookmarkedIds.clear();
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['items'] is List)
              ? (res.data as Map)['items'] as List
              : [];

      for (final item in items) {
        if (item is Map) {
          final pid = item['product_id'] ?? item['productId'] ?? item['id'];
          if (pid != null) _bookmarkedIds.add(pid.toString());
        }
      }
      return Set<String>.from(_bookmarkedIds);
    }

    if (res.statusCode == 0) {
      throw BookmarkException('Network connection failed. Could not load bookmarks.',
          statusCode: 0, isNetworkError: true);
    }

    throw BookmarkException(
      res.errorMessage ?? 'Failed to load bookmarks (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Retrieve full hydrated Product objects for all bookmarked products.
  Future<List<Product>> getBookmarkedProducts({String? deviceId}) async {
    final query = <String, String>{};
    if (deviceId != null && deviceId.isNotEmpty) {
      query['device_id'] = deviceId;
    }

    final res = await _apiClient.get(
      '/bookmarks',
      queryParams: query.isNotEmpty ? query : null,
    );

    if (res.isSuccess) {
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['items'] is List)
              ? (res.data as Map)['items'] as List
              : [];

      final products = <Product>[];
      for (final item in items) {
        if (item is Map) {
          final productMap = item['product'];
          if (productMap is Map<String, dynamic>) {
            products.add(Product.fromJson(productMap));
            final pid = productMap['id'] ?? item['product_id'];
            if (pid != null) _bookmarkedIds.add(pid.toString());
          } else if (item['id'] != null && item['name'] != null) {
            products.add(Product.fromJson(Map<String, dynamic>.from(item)));
            _bookmarkedIds.add(item['id'].toString());
          }
        }
      }
      return products;
    }

    if (res.statusCode == 0) {
      throw BookmarkException('Network connection failed. Could not load bookmarks.',
          statusCode: 0, isNetworkError: true);
    }

    throw BookmarkException(
      res.errorMessage ?? 'Failed to load bookmarks (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Toggle bookmark status for a product ID.
  Future<bool> toggleBookmark(String id, {String? deviceId}) async {
    final willAdd = !_bookmarkedIds.contains(id);
    if (willAdd) {
      final body = <String, dynamic>{'product_id': id};
      if (deviceId != null) body['device_id'] = deviceId;

      final res = await _apiClient.post('/bookmarks', body: body);
      if (res.isSuccess) {
        _bookmarkedIds.add(id);
        return true;
      }
      throw BookmarkException(res.errorMessage ?? 'Failed to add bookmark.',
          statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
    } else {
      final res = await _apiClient.delete('/bookmarks/$id');
      if (res.isSuccess || res.statusCode == 404) {
        _bookmarkedIds.remove(id);
        return false;
      }
      throw BookmarkException(res.errorMessage ?? 'Failed to remove bookmark.',
          statusCode: res.statusCode, isNetworkError: res.statusCode == 0);
    }
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  /// Synchronize guest bookmarks into registered user account on login.
  Future<void> syncBookmarks(Set<String> guestIds, {String? guestToken, String? deviceId}) async {
    _bookmarkedIds.addAll(guestIds);
    try {
      final body = <String, dynamic>{
        'product_ids': guestIds.toList(),
      };
      if (guestToken != null) body['guest_token'] = guestToken;
      if (deviceId != null) body['device_id'] = deviceId;
      await _apiClient.post('/bookmarks/sync', body: body, timeout: const Duration(milliseconds: 3000));
    } catch (_) {}
  }

  /// Isolated demo bookmarks for offline test environments only.
  List<Product> getDemoBookmarks() {
    return mock.products.take(3).toList();
  }
}

