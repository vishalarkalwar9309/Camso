import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:camso_mobile/core/api/api_client.dart';
import 'package:camso_mobile/models/product.dart';
import 'package:camso_mobile/repositories/product_repository.dart';
import 'package:camso_mobile/screens/home_screen.dart';
import 'package:camso_mobile/screens/products_screen.dart';
import 'package:camso_mobile/screens/product_listing_screen.dart';
import 'package:camso_mobile/screens/product_detail_screen.dart';
import 'package:camso_mobile/state/app_state.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Product Model Parsing Tests', () {
    test('Parses authentic Prisma backend format with spec_key, spec_value, and images', () {
      final backendJson = {
        'id': 'cmv_prod_001',
        'pid': 'SKS-S1-10-16.5',
        'name': 'SKS S1 Skid Steer Tire',
        'slug': 'sks-s1-skid-steer-tire',
        'description': 'Heavy-duty skid steer tire engineered for harsh surfaces.',
        'category_id': 'cmv_cat_skid',
        'is_active': true,
        'category': {
          'id': 'cmv_cat_skid',
          'name': 'Skid Steer Tires',
          'slug': 'skid-steer',
        },
        'images': [
          {
            'id': 'img_01',
            'url': 'https://example.com/sks-s1.jpg',
            'is_primary': true,
            'sort_order': 0,
          }
        ],
        'specifications': [
          {
            'id': 'spec_01',
            'spec_type': 'DIMENSION',
            'spec_key': 'Size',
            'spec_value': '10-16.5',
            'unit': null,
          },
          {
            'id': 'spec_02',
            'spec_type': 'SPECIFICATION',
            'spec_key': 'Ply Rating',
            'spec_value': '10',
            'unit': 'PR',
          },
          {
            'id': 'spec_03',
            'spec_type': 'DIMENSION',
            'spec_key': 'Tread Depth',
            'spec_value': '22',
            'unit': 'mm',
          },
          {
            'id': 'spec_04',
            'spec_type': 'PERFORMANCE',
            'spec_key': 'Load Index',
            'spec_value': '128',
            'unit': 'A8',
          },
          {
            'id': 'spec_05',
            'spec_type': 'PERFORMANCE',
            'spec_key': 'Max Load',
            'spec_value': '2,630',
            'unit': 'kg',
          },
          {
            'id': 'spec_06',
            'spec_type': 'PERFORMANCE',
            'spec_key': 'Max Speed',
            'spec_value': '40',
            'unit': 'km/h',
          },
        ],
        'is_new': true,
        'is_featured': true,
      };

      final product = Product.fromJson(backendJson);

      expect(product.id, 'cmv_prod_001');
      expect(product.pid, 'SKS-S1-10-16.5');
      expect(product.name, 'SKS S1 Skid Steer Tire');
      expect(product.category, 'cmv_cat_skid');
      expect(product.categoryName, 'Skid Steer Tires');
      expect(product.image, 'https://example.com/sks-s1.jpg');
      expect(product.size, '10-16.5');
      expect(product.plyRating, '10 PR');
      expect(product.treadDepth, '22 mm');
      expect(product.loadIndex, '128 A8');
      expect(product.maxLoad, '2,630 kg');
      expect(product.maxSpeed, '40 km/h');
      expect(product.isNew, true);
      expect(product.isFeatured, true);
      expect(product.isDiscontinued, false);
      expect(product.specifications['Size'], '10-16.5');
      expect(product.specifications['Ply Rating'], '10 PR');
    });

    test('Parses legacy prototype/mock format correctly', () {
      final legacyJson = {
        'id': 'p002',
        'pid': 'TLH-550',
        'name': 'TLH 550 Telehandler Tire',
        'category': 'cat-2',
        'categoryName': 'Telehandler Tires',
        'image': 'https://example.com/tlh550.png',
        'size': '400/70-20',
        'plyRating': '16 PR',
        'treadDepth': '28 mm',
        'loadIndex': '149 A8',
        'maxLoad': '3250 kg',
        'maxSpeed': '50 km/h',
        'description': 'Telehandler durability.',
        'features': ['Heavy lugs', 'Reinforced bead'],
        'applications': ['Material Handling'],
        'compatibleEquipment': ['JCB 540'],
        'specifications': {
          'Size': '400/70-20',
          'Ply Rating': '16 PR',
        },
        'isNew': false,
        'isFeatured': true,
      };

      final product = Product.fromJson(legacyJson);

      expect(product.id, 'p002');
      expect(product.pid, 'TLH-550');
      expect(product.category, 'cat-2');
      expect(product.categoryName, 'Telehandler Tires');
      expect(product.image, 'https://example.com/tlh550.png');
      expect(product.size, '400/70-20');
      expect(product.features.length, 2);
      expect(product.applications.length, 1);
      expect(product.compatibleEquipment.length, 1);
      expect(product.isNew, false);
      expect(product.isFeatured, true);
    });

    test('Handles missing and empty fields gracefully without crashing', () {
      final emptyJson = <String, dynamic>{};
      final product = Product.fromJson(emptyJson);

      expect(product.id, '');
      expect(product.name, '');
      expect(product.pid, '');
      expect(product.size, 'Standard');
      expect(product.plyRating, 'N/A');
      expect(product.isDiscontinued, false);
      expect(product.image, 'assets/images/camso_default.png');
    });
  });

  group('ProductRepository API Integration Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    test('getProducts() parses 200 OK list from backend', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/products');
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['pageSize'], '20');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'prod_1',
                'name': 'Camso Xtreme 1',
                'pid': 'PID-001',
                'category_id': 'cat_skid',
                'description': 'Xtreme performance',
                'images': [{'url': 'https://example.com/1.png'}],
                'specifications': [],
              },
              {
                'id': 'prod_2',
                'name': 'Camso Xtreme 2',
                'pid': 'PID-002',
                'category_id': 'cat_skid',
                'description': 'Xtreme performance 2',
                'images': [{'url': 'https://example.com/2.png'}],
                'specifications': [],
              },
            ],
            'meta': {'page': 1, 'pageSize': 20, 'total': 2, 'totalPages': 1},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final products = await repo.getProducts();

      expect(products.length, 2);
      expect(products[0].name, 'Camso Xtreme 1');
      expect(products[1].name, 'Camso Xtreme 2');
    });

    test('getProducts() returns empty list when backend returns empty array (no silent mock fallback)', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [],
            'meta': {'page': 1, 'pageSize': 20, 'total': 0, 'totalPages': 0},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final products = await repo.getProducts(categoryId: 'cat-nonexistent');

      expect(products, isEmpty);
    });

    test('getProducts() passes category, query, sort, and spec parameters correctly', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.queryParameters['category'], 'skid-steer');
        expect(request.url.queryParameters['q'], 'SKS');
        expect(request.url.queryParameters['sort'], 'name_asc');
        expect(request.url.queryParameters['spec_width'], '300mm');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final prods = await repo.getProducts(
        categoryId: 'skid-steer',
        query: 'SKS',
        sort: 'name_asc',
        specFilters: {'width': '300mm'},
      );

      expect(prods, isEmpty);
    });

    test('getProducts() throws ProductException on 500 server error (no silent mock fallback)', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {'message': 'Database connection pool exhausted.'},
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);

      expect(
        () => repo.getProducts(),
        throwsA(isA<ProductException>().having(
          (e) => e.message,
          'message',
          contains('Database connection pool exhausted.'),
        )),
      );
    });

    test('getProducts() throws ProductException on network failure', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        throw http.ClientException('Connection refused');
      }));

      final repo = ProductRepository(apiClient: apiClient);

      expect(
        () => repo.getProducts(),
        throwsA(isA<ProductException>().having(
          (e) => e.message,
          'message',
          contains('Connection refused'),
        )),
      );
    });

    test('getProductById() returns Product on 200 OK', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/products/SKS-S1-10-16.5');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'prod_sks',
              'pid': 'SKS-S1-10-16.5',
              'name': 'SKS S1 Skid Steer Tire',
              'description': 'Details for SKS',
              'images': [{'url': 'https://example.com/sks.png'}],
              'specifications': [
                {'spec_key': 'Ply Rating', 'spec_value': '10 PR'}
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final product = await repo.getProductById('SKS-S1-10-16.5');

      expect(product, isNotNull);
      expect(product!.pid, 'SKS-S1-10-16.5');
      expect(product.plyRating, '10 PR');
    });

    test('getProductById() returns null on 404 Not Found', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {'message': 'Product not found.'},
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final product = await repo.getProductById('UNKNOWN_PRODUCT');

      expect(product, isNull);
    });

    test('getCategories() returns standardized list of categories from /api/v1/categories', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/categories');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'cat_1',
                'name': 'Skid Steer Tires',
                'slug': 'skid-steer',
                'description': 'Heavy-duty tires',
                'icon_url': 'https://example.com/skid.png',
                'product_count': 12,
              },
              {
                'id': 'cat_2',
                'name': 'Rubber Tracks',
                'slug': 'rubber-tracks',
                'description': 'High-durability tracks',
                'icon_url': 'https://example.com/tracks.png',
                'product_count': 8,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final categories = await repo.getCategories();

      expect(categories.length, 2);
      expect(categories[0]['name'], 'Skid Steer Tires');
      expect(categories[0]['slug'], 'skid-steer');
      expect(categories[0]['count'], 12);
      expect(categories[1]['name'], 'Rubber Tracks');
    });

    test('getCategories() throws ProductException on server error', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response('Internal Server Error', 500);
      }));

      final repo = ProductRepository(apiClient: apiClient);

      expect(
        () => repo.getCategories(),
        throwsA(isA<ProductException>()),
      );
    });

    test('getDemoProducts() returns isolated prototype items without calling API', () {
      final repo = ProductRepository(apiClient: apiClient);
      final demoList = repo.getDemoProducts();

      expect(demoList, isNotEmpty);
      expect(demoList.any((p) => p.name.contains('Skid Steer')), true);
    });
  });

  group('Catalogue Screens Widget Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    testWidgets('ProductsScreen displays categories and stats from API', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/categories') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'cat_1',
                  'name': 'Skid Steer Tires',
                  'slug': 'skid-steer',
                  'icon_url': 'https://example.com/skid.png',
                  'product_count': 5,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/api/v1/products') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'p1',
                  'name': 'SKS S1',
                  'pid': 'PID-01',
                  'category_id': 'cat_1',
                  'images': [],
                  'specifications': [],
                }
              ],
              'meta': {'total': 1},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      final repo = ProductRepository(apiClient: apiClient);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductsScreen(repository: repo),
          ),
        ),
      );

      // Verify loading state is shown initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Settle async API calls
      await tester.pumpAndSettle();

      // Verify loaded content
      expect(find.text('PRODUCTS'), findsOneWidget);
      expect(find.text('Skid Steer Tires'), findsOneWidget);
      expect(find.text('Total Products'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // 1 product and 1 category
    });

    testWidgets('ProductsScreen displays error state with retry on failure', (tester) async {
      int requestCount = 0;
      apiClient.setClientForTesting(MockHttpClient((request) async {
        requestCount++;
        if (requestCount <= 2) {
          return http.Response(
            jsonEncode({
              'success': false,
              'error': {'message': 'Catalogue service temporarily unavailable'},
            }),
            503,
            headers: {'content-type': 'application/json'},
          );
        }
        // On retry, succeed
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'cat_1',
                'name': 'Recovered Category',
                'slug': 'recovered',
                'icon_url': '',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductsScreen(repository: repo),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error state
      expect(find.text('Unable to Load Catalogue'), findsOneWidget);
      expect(find.textContaining('Catalogue service temporarily unavailable'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      // Tap retry
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      // Verify recovered
      expect(find.text('Recovered Category'), findsOneWidget);
    });

    testWidgets('ProductListingScreen loads products by category with filter chips and sort', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/products') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'p1',
                  'name': 'Alpha SKS Tire',
                  'pid': 'PID-A',
                  'category_id': 'skid-steer',
                  'category': {'name': 'Skid Steer Tires'},
                  'images': [{'url': 'https://example.com/alpha.png'}],
                  'specifications': [],
                  'is_new': true,
                  'is_featured': false,
                  'rating': 4.5,
                },
                {
                  'id': 'p2',
                  'name': 'Beta SKS Tire',
                  'pid': 'PID-B',
                  'category_id': 'skid-steer',
                  'category': {'name': 'Skid Steer Tires'},
                  'images': [{'url': 'https://example.com/beta.png'}],
                  'specifications': [],
                  'is_new': false,
                  'is_featured': true,
                  'rating': 4.9,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      final repo = ProductRepository(apiClient: apiClient);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductListingScreen(
              categoryId: 'skid-steer',
              categoryName: 'Skid Steer Tires',
              repository: repo,
            ),
          ),
        ),
      );

      // Initially shows loading
      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpAndSettle();

      // Loaded products (appears in header and product cards)
      expect(find.text('Skid Steer Tires'), findsWidgets);
      expect(find.text('2 products'), findsOneWidget);
      expect(find.text('Alpha SKS Tire'), findsOneWidget);
      expect(find.text('Beta SKS Tire'), findsOneWidget);

      // Tap 'New' filter chip
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha SKS Tire'), findsOneWidget);
      expect(find.text('Beta SKS Tire'), findsNothing);
      expect(find.text('1 results'), findsOneWidget);

      // Tap 'Featured' filter chip
      await tester.tap(find.text('Featured'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha SKS Tire'), findsNothing);
      expect(find.text('Beta SKS Tire'), findsOneWidget);

      // Tap 'All' filter chip
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha SKS Tire'), findsOneWidget);
      expect(find.text('Beta SKS Tire'), findsOneWidget);
    });

    testWidgets('ProductListingScreen displays error state with retry on failure', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {'message': 'Connection timeout to backend.'},
          }),
          408,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductListingScreen(
              categoryId: 'skid-steer',
              repository: repo,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load products'), findsOneWidget);
      expect(find.textContaining('Connection timeout'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Try Again'), findsOneWidget);
    });

    testWidgets('ProductDetailScreen displays initial product and updates specifications from API', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/products/prod_100') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'prod_100',
                'pid': 'CAM-400-HD',
                'name': 'Camso 400 Heavy Duty',
                'category_id': 'skid-steer',
                'category': {'name': 'Skid Steer Tires'},
                'description': 'Updated description from live server.',
                'images': [{'url': 'https://example.com/live.jpg'}],
                'specifications': [
                  {
                    'spec_key': 'Ply Rating',
                    'spec_value': '14',
                    'unit': 'PR',
                  },
                  {
                    'spec_key': 'Tread Depth',
                    'spec_value': '32',
                    'unit': 'mm',
                  },
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      final repo = ProductRepository(apiClient: apiClient);

      const initialProduct = Product(
        id: 'prod_100',
        name: 'Camso 400',
        pid: 'CAM-400-HD',
        category: 'skid-steer',
        categoryName: 'Skid Steer',
        size: '12-16.5',
        plyRating: '10 PR',
        treadDepth: '22 mm',
        loadIndex: '128',
        maxLoad: '2500 kg',
        maxSpeed: '40 km/h',
        description: 'Initial description.',
        features: [],
        applications: [],
        compatibleEquipment: [],
        specifications: {},
        image: 'https://example.com/initial.jpg',
        isNew: false,
        isFeatured: true,
        rating: 4.8,
        reviewCount: 10,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            home: ProductDetailScreen(
              product: initialProduct,
              repository: repo,
            ),
          ),
        ),
      );

      // Verify initial rendering
      expect(find.text('Camso 400'), findsOneWidget);

      // Let async refresh complete
      await tester.pumpAndSettle();

      // Verify updated product details are displayed
      expect(find.text('Camso 400 Heavy Duty'), findsOneWidget);
      expect(find.text('Updated description from live server.'), findsOneWidget);

      // Tap Specs tab
      await tester.tap(find.text('Specs'));
      await tester.pumpAndSettle();

      expect(find.text('Ply Rating'), findsOneWidget);
      expect(find.text('14 PR'), findsOneWidget);
      expect(find.text('Tread Depth'), findsOneWidget);
      expect(find.text('32 mm'), findsOneWidget);
    });

    testWidgets('HomeScreen loads and displays categories and featured products from repository', (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/categories') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'cat_skid',
                  'name': 'Skid Steer Range',
                  'slug': 'skid-steer',
                  'icon_url': '',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path == '/api/v1/products') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'feat_1',
                  'name': 'Featured Titan Tire',
                  'pid': 'TT-01',
                  'category_id': 'cat_skid',
                  'is_featured': true,
                  'images': [],
                  'specifications': [],
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      }));

      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PRODUCT CATEGORIES'), findsOneWidget);
      expect(find.text('Skid Steer Range'), findsOneWidget);
      expect(find.text('FEATURED PRODUCTS'), findsOneWidget);
      expect(find.text('Featured Titan Tire'), findsOneWidget);
    });
  });
}
