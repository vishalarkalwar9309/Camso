import 'dart:async';

import '../core/api/api_client.dart';
import '../data/mock_data.dart';
import '../models/product.dart';

/// Custom exception thrown when product or category operations fail.
class ProductException implements Exception {
  final String message;
  final int? statusCode;

  const ProductException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Product & Category Data Access Repository.
///
/// Connects to documented backend endpoints:
/// - GET    /api/v1/categories
/// - GET    /api/v1/categories/:id
/// - GET    /api/v1/categories/:id/products
/// - GET    /api/v1/categories/:id/filters
/// - GET    /api/v1/products?category=&q=&page=&pageSize=&sort=
/// - GET    /api/v1/products/:idOrSlug
/// - POST   /api/v1/admin/products
/// - PUT    /api/v1/admin/products/:id
/// - DELETE /api/v1/admin/products/:id
/// - POST   /api/v1/admin/categories
/// - PUT    /api/v1/admin/categories/:id
/// - DELETE /api/v1/admin/categories/:id
class ProductRepository {
  final ApiClient _apiClient;

  ProductRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetch all active products with optional category, search query, or spec filters.
  ///
  /// Throws [ProductException] on backend error or network failure.
  /// Never returns mock products as a silent fallback when the server fails.
  Future<List<Product>> getProducts({
    String? categoryId,
    String? query,
    int page = 1,
    int pageSize = 20,
    String sort = 'newest',
    Map<String, String>? specFilters,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'sort': sort,
    };

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      queryParams['category'] = categoryId;
    }

    if (query != null && query.trim().isNotEmpty) {
      queryParams['q'] = query.trim();
    }

    if (specFilters != null) {
      specFilters.forEach((key, val) {
        if (val.isNotEmpty) {
          queryParams['spec_$key'] = val;
        }
      });
    }

    final res = await _apiClient.get(
      '/products',
      queryParams: queryParams,
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data != null) {
      final rawList = (res.data is List)
          ? res.data as List
          : (res.data is Map && res.data['items'] is List)
              ? res.data['items'] as List
              : (res.data is Map && res.data['products'] is List)
                  ? res.data['products'] as List
                  : null;

      if (rawList != null) {
        return rawList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to load products.',
      statusCode: res.statusCode,
    );
  }

  /// Get a single product by ID, PID, or slug.
  ///
  /// Returns null if the product is not found (404).
  /// Throws [ProductException] on server or network error.
  Future<Product?> getProductById(String idOrSlug) async {
    final res = await _apiClient.get(
      '/products/$idOrSlug',
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data is Map) {
      return Product.fromJson(res.data as Map<String, dynamic>);
    }

    if (res.statusCode == 404) {
      return null;
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to load product details.',
      statusCode: res.statusCode,
    );
  }

  /// Fetch all category tree items from the backend.
  ///
  /// Throws [ProductException] on backend error or network failure.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _apiClient.get(
      '/categories',
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data is List) {
      final rawList = res.data as List;
      return rawList.map((item) {
        final map = (item is Map)
            ? Map<String, dynamic>.from(item)
            : <String, dynamic>{};
        return <String, dynamic>{
          'id': map['id']?.toString() ?? '',
          'name': map['name']?.toString() ?? '',
          'slug': map['slug']?.toString() ?? '',
          'description': map['description']?.toString() ?? '',
          'image': map['icon_url']?.toString() ??
              map['banner_url']?.toString() ??
              map['image']?.toString() ??
              '',
          'icon_url': map['icon_url']?.toString(),
          'banner_url': map['banner_url']?.toString(),
          'count': map['product_count'] ??
              (map['products'] is List ? (map['products'] as List).length : null),
          'children': (map['children'] is List)
              ? List<Map<String, dynamic>>.from(map['children'] as List)
              : const <Map<String, dynamic>>[],
        };
      }).toList();
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to load categories.',
      statusCode: res.statusCode,
    );
  }

  /// Fetch category products using the dedicated `/categories/:id/products` endpoint.
  Future<List<Product>> getCategoryProducts(
    String categoryId, {
    int page = 1,
    int pageSize = 20,
    String sort = 'newest',
  }) async {
    final res = await _apiClient.get(
      '/categories/$categoryId/products',
      queryParams: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'sort': sort,
      },
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data != null) {
      final rawList = (res.data is Map && res.data['products'] is List)
          ? res.data['products'] as List
          : (res.data is List)
              ? res.data as List
              : null;

      if (rawList != null) {
        return rawList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to load category products.',
      statusCode: res.statusCode,
    );
  }

  /// Fetch available filter specifications for a category.
  Future<List<Map<String, dynamic>>> getCategoryFilters(String categoryId) async {
    final res = await _apiClient.get(
      '/categories/$categoryId/filters',
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data as List);
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to load category filters.',
      statusCode: res.statusCode,
    );
  }

  // =========================================================================
  // Explicitly isolated prototype demo data access
  // Used only when isolated offline demo mode is specifically invoked.
  // =========================================================================

  /// Prototype demo products (isolated from normal API operation).
  List<Product> getDemoProducts() => List<Product>.unmodifiable(products);

  /// Prototype demo categories (isolated from normal API operation).
  List<Map<String, dynamic>> getDemoCategories() =>
      List<Map<String, dynamic>>.unmodifiable(categories);

  // =========================================================================
  // Admin Methods (CMS)
  // =========================================================================

  Future<Product> addProduct(Product product) async {
    final res = await _apiClient.post('/admin/products', body: {
      'name': product.name,
      'pid': product.pid,
      'category_id': product.category,
      'description': product.description,
    }, timeout: const Duration(seconds: 10));

    if (res.isSuccess && res.data != null) {
      if (res.data is Map<String, dynamic>) {
        return Product.fromJson(res.data as Map<String, dynamic>);
      } else if (res.data is Map) {
        return Product.fromJson(Map<String, dynamic>.from(res.data as Map));
      }
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to create product.',
      statusCode: res.statusCode,
    );
  }

  Future<void> updateProduct(Product product) async {
    final res = await _apiClient.patch('/admin/products/${product.id}', body: {
      'name': product.name,
      'description': product.description,
    }, timeout: const Duration(seconds: 10));

    if (!res.isSuccess) {
      throw ProductException(
        res.errorMessage ?? 'Failed to update product.',
        statusCode: res.statusCode,
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    final res = await _apiClient.patch(
      '/admin/products/$id',
      body: {'is_active': false},
      timeout: const Duration(seconds: 10),
    );

    if (!res.isSuccess) {
      throw ProductException(
        res.errorMessage ?? 'Failed to delete product.',
        statusCode: res.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> addCategory(Map<String, dynamic> category) async {
    final body = <String, dynamic>{
      'name': category['name'],
      if (category['slug'] != null) 'slug': category['slug'],
      if (category['description'] != null) 'description': category['description'],
      if (category['icon_url'] != null) 'icon_url': category['icon_url'],
      if (category['banner_url'] != null) 'banner_url': category['banner_url'],
      if (category['is_active'] != null) 'is_active': category['is_active'],
    };

    final res = await _apiClient.post(
      '/admin/categories',
      body: body,
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data != null) {
      return Map<String, dynamic>.from(res.data as Map);
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to create category.',
      statusCode: res.statusCode,
    );
  }

  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> category) async {
    final body = <String, dynamic>{
      if (category['name'] != null) 'name': category['name'],
      if (category['slug'] != null) 'slug': category['slug'],
      if (category['description'] != null) 'description': category['description'],
      if (category['icon_url'] != null) 'icon_url': category['icon_url'],
      if (category['banner_url'] != null) 'banner_url': category['banner_url'],
      if (category['is_active'] != null) 'is_active': category['is_active'],
    };

    final res = await _apiClient.patch(
      '/admin/categories/$id',
      body: body,
      timeout: const Duration(seconds: 10),
    );

    if (res.isSuccess && res.data != null) {
      return Map<String, dynamic>.from(res.data as Map);
    }

    throw ProductException(
      res.errorMessage ?? 'Failed to update category.',
      statusCode: res.statusCode,
    );
  }

  Future<void> deleteCategory(String id) async {
    // Backend categories route does not register DELETE /api/v1/admin/categories/:id.
    // In accordance with backend design, category deactivation is performed via PATCH with is_active: false.
    final res = await _apiClient.patch(
      '/admin/categories/$id',
      body: {'is_active': false},
      timeout: const Duration(seconds: 10),
    );

    if (!res.isSuccess) {
      throw ProductException(
        res.errorMessage ?? 'Failed to deactivate category.',
        statusCode: res.statusCode,
      );
    }
  }
}
