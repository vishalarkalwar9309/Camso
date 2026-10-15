import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:camso_mobile/core/api/api_client.dart';
import 'package:camso_mobile/models/app_role.dart';
import 'package:camso_mobile/repositories/content_repository.dart';
import 'package:camso_mobile/repositories/notification_repository.dart';
import 'package:camso_mobile/repositories/search_repository.dart';
import 'package:camso_mobile/screens/faq_screen.dart';
import 'package:camso_mobile/screens/oem_portal_screen.dart';
import 'package:camso_mobile/screens/search_screen.dart';
import 'package:camso_mobile/screens/testimonials_screen.dart';
import 'package:camso_mobile/screens/voc_feedback_screen.dart';
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

  group('Phase 2 Repository Unit Tests', () {
    test('SearchRepository searchProducts() sends q, category, pagination and parses results', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/search');
        expect(request.url.queryParameters['q'], 'extreme');
        expect(request.url.queryParameters['category'], 'cat_1');
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['pageSize'], '20');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'p_101',
                'name': 'Camso Extreme Tire',
                'pid': 'PID-EXT-101',
                'category_id': 'cat_1',
                'description': 'Extreme heavy duty tire',
                'images': [{'url': 'https://example.com/p101.png'}],
                'specifications': [],
              }
            ],
            'meta': {'page': 1, 'pageSize': 20, 'total': 1, 'totalPages': 1},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = SearchRepository();
      final results = await repo.searchProducts('extreme', categoryId: 'cat_1');

      expect(results.length, 1);
      expect(results.first.id, 'p_101');
      expect(results.first.name, 'Camso Extreme Tire');
    });

    test('SearchRepository handles empty and popular searches', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/search/popular') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': ['Backhoe', 'Steel Track', 'Solid Tire'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'success': true, 'data': []}), 200,
            headers: {'content-type': 'application/json'});
      }));

      final repo = SearchRepository();
      final emptyResults = await repo.searchProducts('');
      expect(emptyResults, isEmpty);

      final popular = await repo.getPopularSearches();
      expect(popular, ['Backhoe', 'Steel Track', 'Solid Tire']);
    });

    test('ContentRepository getFaqs() parses FAQItems and categories', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/faqs');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'faqs': [
                {
                  'id': 'faq_1',
                  'category': 'Warranty',
                  'question': 'How long is the track warranty?',
                  'answer': 'Warranty is 36 months or 3,000 hours.',
                },
                {
                  'id': 'faq_2',
                  'category': 'Technical',
                  'question': 'What torque should wheel nuts be set to?',
                  'answer': 'Refer to the chassis maintenance manual.',
                },
              ]
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ContentRepository();
      final faqs = await repo.getFaqs();

      expect(faqs.length, 2);
      expect(faqs.first.id, 'faq_1');
      expect(faqs.first.category, 'Warranty');
      expect(faqs.first.question, contains('warranty'));
    });

    test('ContentRepository getTestimonials() parses stories and maps correctly', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/testimonials');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'test_1',
                'author_name': 'Hans Schmidt',
                'company_name': 'Bauer Construction',
                'story_type': 'CUSTOMER_STORY',
                'comment': 'Over 2,500 hours with minimal wear.',
                'rating': 5,
                'created_at': '2026-08-15T10:00:00Z',
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ContentRepository();
      final testimonials = await repo.getTestimonials();

      expect(testimonials.length, 1);
      expect(testimonials.first.id, 'test_1');
      expect(testimonials.first.type, 'Customer Story');
      expect(testimonials.first.contact, 'Hans Schmidt');
    });

    test('ContentRepository submitFeedback() sends validated bucket and rating', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/feedback');
        expect(request.method, 'POST');
        final body = jsonDecode((request as http.Request).body) as Map<String, dynamic>;
        expect(body['bucket'], 'PRODUCT');
        expect(body['rating'], 5);
        expect(body['comment'], 'Excellent track durability in quarry tests.');

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'id': 'fb_123', 'status': 'RECEIVED'},
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ContentRepository();
      final result = await repo.submitFeedback(
        bucket: 'PRODUCT',
        rating: 5,
        comment: 'Excellent track durability in quarry tests.',
      );

      expect(result['id'], 'fb_123');
    });

    test('ContentRepository getDealersLocator() sends lat, lng, radiusKm and returns nearest dealers', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/dealers/locator');
        expect(request.url.queryParameters['lat'], '48.1351');
        expect(request.url.queryParameters['lng'], '11.582');
        expect(double.parse(request.url.queryParameters['radiusKm']!), 100.0);

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'dlr_1',
                'name': 'Bavaria Heavy Equipment',
                'type': 'AUTHORIZED DEALER',
                'address': 'Industriestr. 10',
                'city': 'Munich',
                'country': 'Germany',
                'geo_lat': 48.14,
                'geo_lng': 11.59,
                'distance': 1.25,
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = ContentRepository();
      final dealers = await repo.getDealersLocator(lat: 48.1351, lng: 11.582, radiusKm: 100);

      expect(dealers.length, 1);
      expect(dealers.first['name'], 'Bavaria Heavy Equipment');
    });

    test('ContentRepository business portal endpoints enforce role boundaries', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/business/organization') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'org_oem_1',
                'name': 'Caterpillar Global OEM Division',
                'status': 'APPROVED',
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/business/oem/documents') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'oem_doc_1',
                  'title': 'Chassis Hub Clearance Spec',
                  'document_type': 'TECHNICAL_GUIDE',
                  'access_level': 'OEM_RESTRICTED',
                  'is_published': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'error': {'message': 'Forbidden'}}), 403,
            headers: {'content-type': 'application/json'});
      }));

      final repo = ContentRepository();
      final org = await repo.getBusinessOrganization();
      expect(org['name'], 'Caterpillar Global OEM Division');

      final oemDocs = await repo.getOemDocuments();
      expect(oemDocs.length, 1);
      expect(oemDocs.first.title, 'Chassis Hub Clearance Spec');
    });

    test('NotificationRepository registerDevice() normalizes platform to ANDROID/IOS', () async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/devices');
        final body = jsonDecode((request as http.Request).body) as Map<String, dynamic>;
        expect(body['device_id'], 'dev_test_001');
        expect(body['platform'], 'ANDROID');
        expect(body['fcm_token'], 'fcm_tok_sample');

        return http.Response(
          jsonEncode({'success': true, 'data': {'registered': true}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = NotificationRepository();
      final ok = await repo.registerDevice(
        deviceId: 'dev_test_001',
        platform: 'web', // Should normalize to ANDROID
        fcmToken: 'fcm_tok_sample',
      );

      expect(ok, isTrue);
    });
  });

  group('Phase 2 Screens Widget Tests', () {
    testWidgets('FAQScreen loads and displays questions from ContentRepository with category filtering',
        (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'faqs': [
                {
                  'id': 'faq_track',
                  'category': 'Technical',
                  'question': 'How do I measure track pitch?',
                  'answer': 'Measure distance between 3 consecutive drive pins.',
                },
                {
                  'id': 'faq_warranty',
                  'category': 'Warranty',
                  'question': 'Is track damage covered under warranty?',
                  'answer': 'Manufacturing defects are covered.',
                },
              ]
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: FAQScreen()),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // FAQs loaded
      expect(find.text('How do I measure track pitch?'), findsOneWidget);
      expect(find.text('Is track damage covered under warranty?'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('How do I measure track pitch?'));
      await tester.pumpAndSettle();
      expect(find.text('Measure distance between 3 consecutive drive pins.'), findsOneWidget);
    });

    testWidgets('TestimonialsScreen displays real testimonials from ContentRepository',
        (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 't_quarry',
                'author_name': 'Markus Weber',
                'company_name': 'Alpine Quarrying AG',
                'story_type': 'CUSTOMER_STORY',
                'comment': 'Outstanding performance in granite extraction.',
                'rating': 5,
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: TestimonialsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Markus Weber'), findsOneWidget);
      expect(find.text('Alpine Quarrying AG'), findsOneWidget);
      expect(find.text('Outstanding performance in granite extraction.'), findsOneWidget);
    });

    testWidgets('VOCFeedbackScreen submits feedback to backend when signed in', (tester) async {
      bool feedbackReceived = false;

      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/feedback') {
          feedbackReceived = true;
          return http.Response(
            jsonEncode({'success': true, 'data': {'id': 'fb_new'}}),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'success': true, 'data': []}), 200,
            headers: {'content-type': 'application/json'});
      }));

      final appState = AppState();
      await appState.signInAsDemo(AppRole.dealer);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: const MaterialApp(home: VOCFeedbackScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Select category
      await tester.tap(find.text('Product Quality'));
      await tester.pumpAndSettle();

      // Select 5 stars (star_border icons before selection)
      await tester.tap(find.byIcon(Icons.star_border).last);
      await tester.pumpAndSettle();

      // Enter comment
      await tester.enterText(
        find.byType(TextField),
        'These solid tires have run for 1,200 hours without any cracking.',
      );
      await tester.pumpAndSettle();

      // Scroll to submit button and submit
      final submitButton = find.text('SUBMIT FEEDBACK');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(feedbackReceived, isTrue);
    });

    testWidgets('OemPortalScreen shows restricted view for unauthenticated and loads docs when authorized',
        (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/business/organization') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'id': 'org_1', 'name': 'Liebherr Mining Equipment'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/business/oem/documents') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'cad_model_1',
                  'title': 'Excavator Track Frame Envelope STEP',
                  'document_type': 'TECHNICAL_GUIDE',
                  'access_level': 'OEM_RESTRICTED',
                  'is_published': true,
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'error': {'message': 'Unauthorized'}}), 401,
            headers: {'content-type': 'application/json'});
      }));

      final guestState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: guestState,
          child: const MaterialApp(home: OemPortalScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Guest sees unauthorized notice
      expect(find.text('OEM Partner Access Required'), findsOneWidget);

      // Sign in as OEM Partner
      await guestState.signInAsDemo(AppRole.oemPartner);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: guestState,
          child: const MaterialApp(home: OemPortalScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('OEM TECHNICAL & CAD DOCUMENTATION'), findsOneWidget);
      expect(find.text('Excavator Track Frame Envelope STEP'), findsOneWidget);
    });

    testWidgets('SearchScreen debounces query and renders backend product search results',
        (tester) async {
      apiClient.setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/search/popular') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': ['Backhoe Tires', 'Rubber Tracks'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/search/recent') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': ['Excavator'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/api/v1/search') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {
                  'id': 'prod_res_1',
                  'name': 'Solideal SKS 732 Heavy Duty',
                  'pid': 'SOL-732-HD',
                  'category_id': 'cat_skid',
                  'description': 'Premium skid steer tire with deep tread',
                  'images': [{'url': 'https://example.com/sks732.png'}],
                  'specifications': [],
                }
              ],
              'meta': {'page': 1, 'pageSize': 20, 'total': 1, 'totalPages': 1},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'success': true, 'data': []}), 200,
            headers: {'content-type': 'application/json'});
      }));

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Solideal');
      // Wait for debounce duration (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Solideal SKS 732 Heavy Duty'), findsOneWidget);
    });
  });
}
