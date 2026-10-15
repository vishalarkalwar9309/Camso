import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:camso_mobile/core/api/api_client.dart';
import 'package:camso_mobile/models/document.dart';
import 'package:camso_mobile/models/notification.dart';
import 'package:camso_mobile/models/product.dart';
import 'package:camso_mobile/repositories/document_repository.dart';
import 'package:camso_mobile/repositories/notification_repository.dart';
import 'package:camso_mobile/repositories/product_repository.dart';
import 'package:camso_mobile/screens/login_screen.dart';
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

  late ApiClient apiClient;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    apiClient = ApiClient();
  });

  tearDown(() {
    apiClient.resetClient();
    apiClient.setAuthToken(null);
  });

  group('Gap 1: Categories CRUD & HTTP Methods', () {
    test('addCategory issues POST /api/v1/admin/categories and returns created category', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/admin/categories');
        final body = jsonDecode((request as http.Request).body);
        expect(body['name'], 'Mining Tracks');
        expect(body['slug'], 'mining-tracks');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'cat_mining_123',
              'name': 'Mining Tracks',
              'slug': 'mining-tracks',
              'is_active': true,
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final created = await repo.addCategory({
        'name': 'Mining Tracks',
        'slug': 'mining-tracks',
      });

      expect(created['id'], 'cat_mining_123');
      expect(created['name'], 'Mining Tracks');
    });

    test('updateCategory issues PATCH /api/v1/admin/categories/:id', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/admin/categories/cat_mining_123');
        final body = jsonDecode((request as http.Request).body);
        expect(body['name'], 'Updated Mining Tracks');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'cat_mining_123',
              'name': 'Updated Mining Tracks',
              'slug': 'mining-tracks',
              'is_active': true,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final updated = await repo.updateCategory('cat_mining_123', {
        'name': 'Updated Mining Tracks',
      });

      expect(updated['name'], 'Updated Mining Tracks');
    });

    test('deleteCategory issues PATCH /api/v1/admin/categories/:id with is_active: false', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/admin/categories/cat_mining_123');
        final body = jsonDecode((request as http.Request).body);
        expect(body['is_active'], false);

        return http.Response(
          jsonEncode({'success': true, 'data': {'id': 'cat_mining_123', 'is_active': false}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      await repo.deleteCategory('cat_mining_123');
    });
  });

  group('Gap 2: Documents CRUD & HTTP Methods', () {
    test('addDocument issues POST /api/v1/admin/documents with document_type and is_published', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/admin/documents');
        final body = jsonDecode((request as http.Request).body);
        expect(body['title'], 'Agricultural Field Guide');
        expect(body['document_type'], 'MANUAL');
        expect(body['is_published'], true);

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'doc_backend_cuid_123',
              'title': 'Agricultural Field Guide',
              'document_type': 'MANUAL',
              'is_published': true,
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = DocumentRepository(apiClient: apiClient);
      const doc = Document(
        id: '',
        title: 'Agricultural Field Guide',
        type: 'Operator Manual',
        category: 'Agriculture',
        fileSize: '3.4 MB',
        format: 'PDF',
        date: '2026-10-15',
        version: '1.0',
        description: 'Field operation guide',
        productId: null,
        pages: 12,
        language: 'en',
        isDownloaded: false,
      );

      final created = await repo.addDocument(doc);
      expect(created.id, 'doc_backend_cuid_123');
      expect(created.title, 'Agricultural Field Guide');
    });

    test('updateDocument issues PATCH /api/v1/admin/documents/:id', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/admin/documents/doc_123');
        final body = jsonDecode((request as http.Request).body);
        expect(body['title'], 'Revised Field Guide');
        expect(body['document_type'], 'MANUAL');

        return http.Response(
          jsonEncode({'success': true, 'data': {'id': 'doc_123', 'title': 'Revised Field Guide'}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = DocumentRepository(apiClient: apiClient);
      const doc = Document(
        id: 'doc_123',
        title: 'Revised Field Guide',
        type: 'Manual',
        category: 'Agriculture',
        fileSize: '3.4 MB',
        format: 'PDF',
        date: '2026-10-15',
        version: '1.1',
        description: 'Revised manual',
        productId: null,
        pages: 12,
        language: 'en',
        isDownloaded: false,
      );

      await repo.updateDocument(doc);
    });

    test('deleteDocument unpublishes via PATCH /api/v1/admin/documents/:id with is_published: false', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/api/v1/admin/documents/doc_123');
        final body = jsonDecode((request as http.Request).body);
        expect(body['is_published'], false);

        return http.Response(
          jsonEncode({'success': true, 'data': {'id': 'doc_123', 'is_published': false}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = DocumentRepository(apiClient: apiClient);
      await repo.deleteDocument('doc_123');
    });
  });

  group('Gap 3: Products Real IDs & State Refresh', () {
    test('addProduct receives backend-assigned ID and does not use synthetic client ID', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/admin/products');
        final body = jsonDecode((request as http.Request).body);
        expect(body['name'], 'Solideal RES 660');
        expect(body['pid'], 'RES-660-X');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'prod_backend_db_cuid_999',
              'name': 'Solideal RES 660',
              'pid': 'RES-660-X',
              'category_id': 'cat_forklift',
              'description': 'Premium resilient solid tire',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ProductRepository(apiClient: apiClient);
      final created = await repo.addProduct(const Product(
        id: '',
        name: 'Solideal RES 660',
        pid: 'RES-660-X',
        category: 'cat_forklift',
        categoryName: 'Material Handling',
        size: '18x7-8',
        plyRating: '16PR',
        treadDepth: '22mm',
        loadIndex: '125A5',
        maxLoad: '2140 kg',
        maxSpeed: '25 km/h',
        description: 'Premium resilient solid tire',
        features: [],
        applications: [],
        compatibleEquipment: [],
        specifications: {},
        image: 'assets/images/camso_default.png',
        isNew: true,
        isFeatured: false,
        rating: 4.8,
        reviewCount: 1,
      ));

      expect(created.id, 'prod_backend_db_cuid_999');
      expect(created.id.startsWith('admin_'), false);
    });
  });

  group('Gap 4: Notifications Error Propagation & Explicit Unsupported Deletion', () {
    test('addNotification propagates backend errors without silent catch', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': {'message': 'Target broadcast failed'}}),
          500,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = NotificationRepository(apiClient: apiClient);
      expect(
        () => repo.addNotification(const AppNotification(
          id: '',
          type: 'SYSTEM',
          title: 'System Alert',
          body: 'Maintenance tonight',
          date: '2026-10-15',
          isRead: false,
          icon: 'info',
        )),
        throwsA(isA<NotificationException>()),
      );
    });

    test('deleteNotification reports explicit 405 error instead of faking success', () async {
      final repo = NotificationRepository(apiClient: apiClient);
      expect(
        () => repo.deleteNotification('notif_123'),
        throwsA(predicate((e) =>
            e is NotificationException &&
            e.statusCode == 405 &&
            e.message.contains('not supported'))),
      );
    });

    test('sendBroadcastNotification sends multicast push via /admin/notifications/send', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/admin/notifications/send');
        final body = jsonDecode((request as http.Request).body);
        expect(body['title'], 'New Catalog Available');
        expect(body['target_type'], 'ALL_USERS');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'targetCount': 150, 'successCount': 148, 'failureCount': 2},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = NotificationRepository(apiClient: apiClient);
      final res = await repo.sendBroadcastNotification(
        title: 'New Catalog Available',
        body: 'Check out the new 2026 agricultural lineup',
      );

      expect(res['targetCount'], 150);
      expect(res['successCount'], 148);
    });
  });

  group('Gap 5: Login Preset Behavior', () {
    testWidgets('Selecting a role preset populates email but leaves password empty', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Find password field
      final passwordFieldFinder = find.byType(TextField).at(1);
      TextField passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(passwordField.controller?.text.isEmpty, true);

      // Verify email field contains dealer preset email
      final emailFieldFinder = find.byType(TextField).at(0);
      TextField emailField = tester.widget<TextField>(emailFieldFinder);
      expect(emailField.controller?.text, 'demo.dealer@camso.local');

      // Tap Distributor role chip
      final distributorChip = find.textContaining('Distributor').first;
      await tester.tap(distributorChip);
      await tester.pumpAndSettle();

      // Verify email updated to distributor and password remains empty
      emailField = tester.widget<TextField>(emailFieldFinder);
      passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(emailField.controller?.text, 'demo.distributor@camso.local');
      expect(passwordField.controller?.text.isEmpty, true);

      // Tap OEM Partner role chip
      final oemChip = find.textContaining('OEM Partner').first;
      await tester.tap(oemChip);
      await tester.pumpAndSettle();

      // Verify email updated to demo.oem@camso.local and password remains empty
      emailField = tester.widget<TextField>(emailFieldFinder);
      passwordField = tester.widget<TextField>(passwordFieldFinder);
      expect(emailField.controller?.text, 'demo.oem@camso.local');
      expect(passwordField.controller?.text.isEmpty, true);
    });
  });

  group('Final Integration Tests: Notifications & Devices', () {
    test('updateNotification issues PATCH /api/v1/admin/notifications/:id', () async {
      String? recordedMethod;
      String? recordedPath;
      Map<String, dynamic>? recordedBody;

      apiClient.setClientForTesting(MockHttpClient((request) async {
        recordedMethod = request.method;
        recordedPath = request.url.path;
        recordedBody = jsonDecode((request as http.Request).body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'id': 'notif_123', 'notification_type': 'PROMOTION'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = NotificationRepository(apiClient: apiClient);
      final updated = await repo.updateNotification(
        const AppNotification(
          id: 'notif_123',
          type: 'PROMOTION',
          title: 'Updated Promo Title',
          body: 'Updated body text',
          date: '2026-10-15',
          isRead: false,
          icon: 'tag',
        ),
      );

      expect(recordedMethod, 'PATCH');
      expect(recordedPath, '/api/v1/admin/notifications/notif_123');
      expect(recordedBody?['translations']?[0]?['value'], 'Updated Promo Title');
      expect(updated.title, 'Updated Promo Title');
    });

    test('registerDevice sends POST /api/v1/devices with device ID and platform', () async {
      String? recordedMethod;
      String? recordedPath;
      Map<String, dynamic>? recordedBody;

      apiClient.setClientForTesting(MockHttpClient((request) async {
        recordedMethod = request.method;
        recordedPath = request.url.path;
        recordedBody = jsonDecode((request as http.Request).body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'id': 'dev_123', 'device_id': 'test_dev_01'},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = NotificationRepository(apiClient: apiClient);
      final success = await repo.registerDevice(
        deviceId: 'test_dev_01',
        platform: 'ANDROID',
        appVersion: '1.0.0',
      );

      expect(success, true);
      expect(recordedMethod, 'POST');
      expect(recordedPath, '/api/v1/devices');
      expect(recordedBody?['device_id'], 'test_dev_01');
      expect(recordedBody?['platform'], 'ANDROID');
    });
  });
}
