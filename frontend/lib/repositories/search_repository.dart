import 'dart:async';
import '../core/api/api_client.dart';
import '../data/mock_data.dart' as mock;
import '../models/product.dart';

/// Exception thrown when a search operation fails.
class SearchException implements Exception {
  final String message;
  final int statusCode;
  final bool isNetworkError;

  const SearchException(this.message, {this.statusCode = 500, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Search and Discovery Data Access Repository.
///
/// Implements documented backend endpoints:
/// - GET /api/v1/search?q=...&category=...&page=...&pageSize=...
/// - GET /api/v1/search/popular
/// - GET /api/v1/search/recent
/// - DELETE /api/v1/search/recent
class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final List<String> _localRecent = <String>[];

  /// Execute ranked product search according to the 6 backend priority tiers.
  Future<List<Product>> searchProducts(
    String query, {
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final queryParams = <String, String>{
      'q': q,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (categoryId != null && categoryId.isNotEmpty && categoryId.toLowerCase() != 'all') {
      queryParams['category'] = categoryId;
    }

    final res = await _apiClient.get('/search', queryParams: queryParams);

    if (res.isSuccess) {
      if (res.data is Map && (res.data as Map)['items'] is List) {
        final list = (res.data as Map)['items'] as List;
        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (res.data is List) {
        return (res.data as List)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    if (res.statusCode == 0) {
      throw SearchException('Network connection failed. Please check your internet connection.',
          statusCode: 0, isNetworkError: true);
    }

    throw SearchException(
      res.errorMessage ?? 'Search failed with status code ${res.statusCode}.',
      statusCode: res.statusCode,
    );
  }

  /// Retrieve top aggregated popular search queries.
  Future<List<String>> getPopularSearches({int limit = 10}) async {
    try {
      final res = await _apiClient.get(
        '/search/popular',
        queryParams: {'limit': limit.toString()},
        timeout: const Duration(milliseconds: 3000),
      );

      if (res.isSuccess && res.data is List) {
        final list = res.data as List;
        return list.map((item) {
          if (item is Map && item['query_text'] != null) {
            return item['query_text'].toString();
          }
          return item.toString();
        }).where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}

    return [
      'skid steer',
      'mini excavator',
      '10-16.5',
      'rubber tracks',
      'telehandler',
      'backhoe',
    ];
  }

  /// Retrieve user recent search queries.
  Future<List<String>> getRecentSearches({int limit = 10}) async {
    try {
      final res = await _apiClient.get(
        '/search/recent',
        queryParams: {'limit': limit.toString()},
        timeout: const Duration(milliseconds: 3000),
      );

      if (res.isSuccess && res.data is List) {
        final list = res.data as List;
        final results = list.map((item) {
          if (item is Map && item['query_text'] != null) {
            return item['query_text'].toString();
          }
          return item.toString();
        }).where((s) => s.isNotEmpty).toList();

        if (results.isNotEmpty) {
          _localRecent.clear();
          _localRecent.addAll(results);
          return results;
        }
      }
    } catch (_) {}

    return List<String>.from(_localRecent);
  }

  /// Add query to local recent cache.
  void addRecentSearch(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    _localRecent.removeWhere((item) => item.toLowerCase() == t.toLowerCase());
    _localRecent.insert(0, t);
    if (_localRecent.length > 8) _localRecent.removeLast();
  }

  /// Clear user's search history.
  Future<void> clearRecentSearches() async {
    _localRecent.clear();
    try {
      await _apiClient.delete('/search/recent', timeout: const Duration(milliseconds: 3000));
    } catch (_) {}
  }

  /// Isolated demo search for offline test environments only.
  List<Product> getDemoSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return mock.products
        .where((p) =>
            !p.isDiscontinued &&
            (p.name.toLowerCase().contains(q) ||
                p.pid.toLowerCase().contains(q) ||
                p.categoryName.toLowerCase().contains(q)))
        .toList();
  }
}

