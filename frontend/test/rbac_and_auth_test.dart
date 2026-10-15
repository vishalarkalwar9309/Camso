import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camso_mobile/core/api/api_client.dart';
import 'package:camso_mobile/core/auth/auth_service.dart';
import 'package:camso_mobile/core/auth/auth_session.dart';
import 'package:camso_mobile/core/permissions/permission_service.dart';
import 'package:camso_mobile/models/app_role.dart';
import 'package:camso_mobile/models/document.dart';
import 'package:camso_mobile/repositories/bookmark_repository.dart';
import 'package:camso_mobile/repositories/document_repository.dart';
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

Document _makeDoc({
  required String id,
  required String title,
  DocumentAccessLevel accessLevel = DocumentAccessLevel.public,
}) {
  return Document(
    id: id,
    title: title,
    type: 'Brochure',
    category: 'brochures',
    fileSize: '1.5 MB',
    format: 'PDF',
    date: '2026',
    version: '1.0',
    description: 'Test document',
    productId: 'p001',
    pages: 4,
    language: 'English',
    isDownloaded: false,
    accessLevel: accessLevel,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    ApiClient().resetClient();
    ApiClient().setAuthToken(null);
  });

  group('Role-Based Access Control (RBAC) Permissions', () {
    test('Guest permissions', () {
      const permissions = PermissionService(AppRole.guest);

      // Documents
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public Brochure', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'Dealer Guide', accessLevel: DocumentAccessLevel.dealer),
        ),
        isFalse,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '3', title: 'Internal Guide', accessLevel: DocumentAccessLevel.employee),
        ),
        isFalse,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '4', title: 'OEM Spec', accessLevel: DocumentAccessLevel.oem),
        ),
        isFalse,
      );

      // Calculators
      expect(permissions.canUseCalculators, isTrue);
      expect(permissions.canSaveCalculatorResults, isFalse);

      // Admin actions
      expect(permissions.canViewAdminAnalytics, isFalse);
      expect(permissions.canManageProducts, isFalse);
    });

    test('Dealer permissions', () {
      const permissions = PermissionService(AppRole.dealer);

      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'Dealer', accessLevel: DocumentAccessLevel.dealer),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '3', title: 'Distributor', accessLevel: DocumentAccessLevel.distributor),
        ),
        isFalse,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '4', title: 'Employee', accessLevel: DocumentAccessLevel.employee),
        ),
        isFalse,
      );

      expect(permissions.canSaveCalculatorResults, isTrue);
    });

    test('Distributor permissions', () {
      const permissions = PermissionService(AppRole.distributor);

      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'Distributor', accessLevel: DocumentAccessLevel.distributor),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '3', title: 'Dealer', accessLevel: DocumentAccessLevel.dealer),
        ),
        isFalse,
      );

      expect(permissions.canSaveCalculatorResults, isTrue);
    });

    test('Employee permissions', () {
      const permissions = PermissionService(AppRole.employee);

      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'Internal', accessLevel: DocumentAccessLevel.employee),
        ),
        isTrue,
      );
      expect(permissions.canViewInternalResources, isTrue);
      expect(permissions.canViewOemResources, isFalse);

      expect(permissions.canSaveCalculatorResults, isTrue);
    });

    test('OEM Partner permissions', () {
      const permissions = PermissionService(AppRole.oemPartner);

      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'OEM', accessLevel: DocumentAccessLevel.oem),
        ),
        isTrue,
      );
      expect(permissions.canViewOemResources, isTrue);
      expect(permissions.canViewInternalResources, isFalse);

      expect(permissions.canSaveCalculatorResults, isTrue);
    });

    test('Admin permissions', () {
      const permissions = PermissionService(AppRole.admin);

      // Admin views all documents
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '1', title: 'Public', accessLevel: DocumentAccessLevel.public),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '2', title: 'Dealer', accessLevel: DocumentAccessLevel.dealer),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '3', title: 'Distributor', accessLevel: DocumentAccessLevel.distributor),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '4', title: 'Employee', accessLevel: DocumentAccessLevel.employee),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '5', title: 'OEM', accessLevel: DocumentAccessLevel.oem),
        ),
        isTrue,
      );
      expect(
        permissions.canViewDocument(
          _makeDoc(id: '6', title: 'Admin', accessLevel: DocumentAccessLevel.admin),
        ),
        isTrue,
      );

      // Admin content management & analytics
      expect(permissions.canViewAdminAnalytics, isTrue);
      expect(permissions.canManageProducts, isTrue);
      expect(permissions.canManageCategories, isTrue);
      expect(permissions.canManageDocuments, isTrue);
      expect(permissions.canManageNotifications, isTrue);
      expect(permissions.canManageProductUpdates, isTrue);

      // Strict scope boundary: User management is excluded
      expect(permissions.canManageUsers, isFalse);
    });
  });

  group('ApiClient Cross-Platform & Security Tests', () {
    test('Successful GET request returns 200 with parsed data', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/test');
        return http.Response(
          jsonEncode({
            'data': {'id': 'item-01', 'name': 'Tire A'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/test');
      expect(res.isSuccess, isTrue);
      expect(res.statusCode, 200);
      expect(res.data['name'], 'Tire A');
    });

    test('Successful POST request sends json body and returns 201', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode((request as http.Request).body);
        expect(body['title'], 'New Document');
        return http.Response(
          jsonEncode({
            'data': {'id': 'doc-123'}
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().post('/documents', body: {'title': 'New Document'});
      expect(res.isSuccess, isTrue);
      expect(res.statusCode, 201);
      expect(res.data['id'], 'doc-123');
    });

    test('401 Unauthorized returns failure with extracted server error message', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/protected');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 401);
      expect(res.errorMessage, 'Invalid credentials');
    });

    test('403 Forbidden returns failure with status 403', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Your account is pending administrator approval.'}),
          403,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/portal');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 403);
      expect(res.errorMessage, 'Your account is pending administrator approval.');
    });

    test('500 Server error returns failure with status 500', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'error': 'Internal server error'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/error');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 500);
      expect(res.errorMessage, 'Internal server error');
    });

    test('Structured error object with inner message extracts clean message without converting object to string', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'type': 'UNAUTHORIZED',
              'message': 'Invalid business email or password.',
              'details': []
            }
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().post('/business-auth/login', body: {'email': 'test@dealer.com'});
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 401);
      expect(res.errorMessage, 'Invalid business email or password.');
      expect(res.errorMessage, isNot(contains('{')));
    });

    test('Plain-string non-JSON error body uses raw string message', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          '502 Bad Gateway: Upstream connection timeout',
          502,
          headers: {'content-type': 'text/plain'},
        );
      }));

      final res = await ApiClient().get('/upstream');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 502);
      expect(res.errorMessage, '502 Bad Gateway: Upstream connection timeout');
    });

    test('Response with malformed JSON and no plain text falls back to status code message', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          '   ',
          500,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/empty');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 500);
      expect(res.errorMessage, 'Request failed with status 500');
    });

    test('Response with empty error object falls back to status code message', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'error': {}}),
          400,
          headers: {'content-type': 'application/json'},
        );
      }));

      final res = await ApiClient().get('/no-message');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 400);
      expect(res.errorMessage, 'Request failed with status 400');
    });

    test('Network connection error returns statusCode 0 and error details', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        throw http.ClientException('Connection refused');
      }));

      final res = await ApiClient().get('/unreachable');
      expect(res.isSuccess, isFalse);
      expect(res.statusCode, 0);
      expect(res.errorMessage, contains('Connection refused'));
    });

    test('Authorization Bearer header is attached when authToken is set', () async {
      String? sentAuthHeader;
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        sentAuthHeader = request.headers['authorization'];
        return http.Response('{"data": true}', 200);
      }));

      ApiClient().setAuthToken('test_jwt_active_token');
      await ApiClient().get('/users/me');

      expect(sentAuthHeader, 'Bearer test_jwt_active_token');
    });

    test('Authorization header is omitted when authToken is cleared', () async {
      String? sentAuthHeader;
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        sentAuthHeader = request.headers['authorization'];
        return http.Response('{"data": true}', 200);
      }));

      ApiClient().setAuthToken(null);
      await ApiClient().get('/public');

      expect(sentAuthHeader, isNull);
    });
  });

  group('AuthService Security & Regression Tests', () {
    test('startGuestSession creates isolated guest session with restricted access', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(jsonEncode({'token': 'guest_token_123'}), 201);
      }));

      final authService = AuthService();
      final session = await authService.startGuestSession();

      expect(session.role, AppRole.guest);
      expect(session.isGuest, isTrue);
      expect(session.organizationName, isNull);
      expect(ApiClient().authToken, isNotEmpty);
    });

    test('login() with invalid credentials (401) throws AuthException and never saves mock session', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid business email or password.'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'wrong@dealer.com',
          password: 'badpassword',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'Invalid business email or password.')),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AuthService.sessionKey), isNull);
      expect(ApiClient().authToken, isNull);
    });

    test('login() with unapproved business account (403) throws AuthException with pending message', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Your account is pending administrator approval.'}),
          403,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'pending@dealer.com',
          password: 'Secret123!',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Your account is pending administrator approval.')),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AuthService.sessionKey), isNull);
      expect(ApiClient().authToken, isNull);
    });

    test('login() with network failure throws AuthException and never silently authenticates', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        throw http.ClientException('Host lookup failed');
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'demo.dealer@camso.local',
          password: 'DealerPassword123!',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>().having((e) => e.statusCode, 'statusCode', 0)),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AuthService.sessionKey), isNull);
      expect(ApiClient().authToken, isNull);
    });

    test('login() with server 500 error throws AuthException and does not fabricate session', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Internal database error'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'admin@camso.com',
          password: 'AdminPassword123!',
          role: AppRole.admin,
        ),
        throwsA(isA<AuthException>().having((e) => e.statusCode, 'statusCode', 500)),
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AuthService.sessionKey), isNull);
      expect(ApiClient().authToken, isNull);
    });

    test('login() succeeds with snake_case tokens for Business Dealer partner', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/business-auth/login');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'tokens': {
                'access_token': 'jwt_business_access_123',
                'refresh_token': 'jwt_business_refresh_123',
              },
              'user': {
                'id': 'usr_dealer_01',
                'email': 'dealer@camso.local',
                'display_name': 'Klaus Schmidt',
              },
              'organization': {
                'id': 'org_dealer_01',
                'name': 'Alpine Equipment GmbH',
                'type': 'DEALER',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      final session = await authService.login(
        email: 'dealer@camso.local',
        password: 'DealerPassword123!',
        role: AppRole.dealer,
      );

      expect(session.role, AppRole.dealer);
      expect(session.isGuest, isFalse);
      expect(session.accessToken, 'jwt_business_access_123');
      expect(session.refreshToken, 'jwt_business_refresh_123');
      expect(session.displayName, 'Klaus Schmidt');
      expect(session.organizationName, 'Alpine Equipment GmbH');
      expect(ApiClient().authToken, 'jwt_business_access_123');
    });

    test('login() succeeds with snake_case tokens for Customer account', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'access_token': 'jwt_customer_access_789',
              'refresh_token': 'jwt_customer_refresh_789',
              'user': {
                'id': 'usr_cust_01',
                'email': 'customer@farm.com',
                'display_name': 'Hans Bauer',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      final session = await authService.login(
        email: 'customer@farm.com',
        password: 'CustPassword123!',
        role: AppRole.guest,
      );

      expect(session.accessToken, 'jwt_customer_access_789');
      expect(session.refreshToken, 'jwt_customer_refresh_789');
      expect(session.displayName, 'Hans Bauer');
      expect(ApiClient().authToken, 'jwt_customer_access_789');
    });

    test('login() succeeds with snake_case tokens and admin object for Admin account', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/admin-auth/login');
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'access_token': 'jwt_admin_access_999',
              'refresh_token': 'jwt_admin_refresh_999',
              'admin': {
                'id': 'admin_01',
                'email': 'superadmin@camso.com',
                'role': 'SUPER_ADMIN',
                'name': 'System Administrator',
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      final session = await authService.login(
        email: 'superadmin@camso.com',
        password: 'AdminPassword123!',
        role: AppRole.admin,
      );

      expect(session.role, AppRole.admin);
      expect(session.accessToken, 'jwt_admin_access_999');
      expect(session.displayName, 'System Administrator');
      expect(ApiClient().authToken, 'jwt_admin_access_999');
    });

    test('login() throws AuthException 500 when access token is missing in 200 response', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user': {'id': 'usr_incomplete'},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'test@camso.com',
          password: 'Password123!',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', contains('did not contain an access token'))),
      );
    });

    test('login() throws AuthException 500 when response body data is not a map', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': 'unexpected string data',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      expect(
        () => authService.login(
          email: 'test@camso.com',
          password: 'Password123!',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', contains('Invalid authentication response'))),
      );
    });

    test('restoreSession() clears stale mock token (jwt_mock_...) and returns null', () async {
      final prefs = await SharedPreferences.getInstance();
      const staleSession = AuthSession(
        userId: 'usr_stale',
        displayName: 'Stale User',
        role: AppRole.dealer,
        accessToken: 'jwt_mock_access_token_1792000000',
        isGuest: false,
      );
      await prefs.setString(AuthService.sessionKey, staleSession.serialize());

      final authService = AuthService();
      final restored = await authService.restoreSession();

      expect(restored, isNull);
      expect(ApiClient().authToken, isNull);
      expect(prefs.getString(AuthService.sessionKey), isNull);
    });

    test('restoreSession() clears session and storage when server returns 401 expired', () async {
      final prefs = await SharedPreferences.getInstance();
      const expiredSession = AuthSession(
        userId: 'usr_expired',
        displayName: 'Expired Dealer',
        role: AppRole.dealer,
        accessToken: 'expired_jwt_token_abc',
        isGuest: false,
      );
      await prefs.setString(AuthService.sessionKey, expiredSession.serialize());

      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Token expired'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      final restored = await authService.restoreSession();

      expect(restored, isNull);
      expect(ApiClient().authToken, isNull);
      expect(prefs.getString(AuthService.sessionKey), isNull);
    });

    test('restoreSession() succeeds when backend validates session with 200', () async {
      final prefs = await SharedPreferences.getInstance();
      const validSession = AuthSession(
        userId: 'usr_valid',
        displayName: 'Active Dealer',
        role: AppRole.dealer,
        accessToken: 'active_valid_token_xyz',
        isGuest: false,
      );
      await prefs.setString(AuthService.sessionKey, validSession.serialize());

      ApiClient().setClientForTesting(MockHttpClient((request) async {
        expect(request.url.path, '/api/v1/business/organization');
        return http.Response(
          jsonEncode({
            'data': {'id': 'org_1', 'name': 'Alpine Equipment'}
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final authService = AuthService();
      final restored = await authService.restoreSession();

      expect(restored, isNotNull);
      expect(restored!.accessToken, 'active_valid_token_xyz');
      expect(ApiClient().authToken, 'active_valid_token_xyz');
    });

    test('logout() revokes auth token on ApiClient and clears persistent storage', () async {
      final prefs = await SharedPreferences.getInstance();
      const session = AuthSession(
        userId: 'usr_to_logout',
        displayName: 'Logout User',
        role: AppRole.admin,
        accessToken: 'token_to_clear',
        isGuest: false,
      );
      await prefs.setString(AuthService.sessionKey, session.serialize());
      ApiClient().setAuthToken('token_to_clear');

      final authService = AuthService();
      await authService.logout();

      expect(ApiClient().authToken, isNull);
      expect(prefs.getString(AuthService.sessionKey), isNull);
    });
  });

  group('AppState Authentication & Role Switcher', () {
    test('AppState handles all 6 roles and login/logout lifecycle', () async {
      final appState = AppState();

      // Starts as guest
      expect(appState.role, AppRole.guest);
      expect(appState.loggedIn, isFalse);

      // Test Dealer
      await appState.signInAsDemo(AppRole.dealer);
      expect(appState.role, AppRole.dealer);
      expect(appState.loggedIn, isTrue);

      // Test Distributor
      await appState.signInAsDemo(AppRole.distributor);
      expect(appState.role, AppRole.distributor);
      expect(appState.loggedIn, isTrue);

      // Test Employee
      await appState.signInAsDemo(AppRole.employee);
      expect(appState.role, AppRole.employee);
      expect(appState.loggedIn, isTrue);

      // Test OEM Partner
      await appState.signInAsDemo(AppRole.oemPartner);
      expect(appState.role, AppRole.oemPartner);
      expect(appState.loggedIn, isTrue);

      // Test Admin
      await appState.signInAsDemo(AppRole.admin);
      expect(appState.role, AppRole.admin);
      expect(appState.loggedIn, isTrue);

      // Sign out restores guest
      await appState.signOut();
      expect(appState.role, AppRole.guest);
      expect(appState.loggedIn, isFalse);
    });

    test('AppState signIn with invalid credentials throws AuthException and leaves user unauthenticated', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Invalid credentials'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }));

      final appState = AppState();
      expect(appState.role, AppRole.guest);
      expect(appState.loggedIn, isFalse);

      expect(
        () => appState.signIn(
          email: 'wrong@dealer.com',
          password: 'badpassword',
          role: AppRole.dealer,
        ),
        throwsA(isA<AuthException>().having((e) => e.statusCode, 'statusCode', 401)),
      );

      expect(appState.role, AppRole.guest);
      expect(appState.loggedIn, isFalse);
    });

    test('AppState enforces that users can only bookmark after sign-in', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/bookmarks') {
          return http.Response(
            jsonEncode({'success': true, 'data': {'id': 'bm_p001'}}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.startsWith('/api/v1/bookmarks/')) {
          return http.Response(
            jsonEncode({'success': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'success': true, 'data': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final appState = AppState();

      // Guest cannot bookmark
      expect(appState.loggedIn, isFalse);
      final guestResult = appState.toggleBookmark('p001');
      expect(guestResult, isFalse);
      expect(appState.isBookmarked('p001'), isFalse);
      expect(appState.bookmarks.contains('p001'), isFalse);

      // Sign in as Dealer
      await appState.signInAsDemo(AppRole.dealer);
      expect(appState.loggedIn, isTrue);

      // Authenticated user can bookmark
      final loggedInResult = appState.toggleBookmark('p001');
      expect(loggedInResult, isTrue);
      expect(appState.isBookmarked('p001'), isTrue);
      expect(appState.bookmarks.contains('p001'), isTrue);

      // Can un-bookmark
      final removeResult = appState.toggleBookmark('p001');
      expect(removeResult, isTrue);
      expect(appState.isBookmarked('p001'), isFalse);
    });

    test('AppState and AppStrings support multilingual translations (EN, FR, DE, IT)', () {
      final appState = AppState();

      // Default EN
      expect(appState.language, 'en');
      expect(appState.tr('nav_home'), 'Home');
      expect(appState.tr('nav_products'), 'Products');

      // French
      appState.setLanguage('fr');
      expect(appState.language, 'fr');
      expect(appState.tr('nav_home'), 'Accueil');
      expect(appState.tr('nav_products'), 'Produits');

      // German
      appState.setLanguage('de');
      expect(appState.language, 'de');
      expect(appState.tr('nav_home'), 'Startseite');
      expect(appState.tr('nav_products'), 'Produkte');

      // Italian
      appState.setLanguage('it');
      expect(appState.language, 'it');
      expect(appState.tr('nav_home'), 'Home');
      expect(appState.tr('nav_products'), 'Prodotti');
    });
  });

  group('Document and Bookmark Repositories', () {
    test('DocumentRepository filters documents by user role', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'doc_pub_1',
                'title': 'Public Brochure 1',
                'document_type': 'CATALOGUE',
                'access_level': 'PUBLIC',
                'is_published': true,
              },
              {
                'id': 'doc_pub_2',
                'title': 'Public Brochure 2',
                'document_type': 'BROCHURE',
                'access_level': 'PUBLIC',
                'is_published': true,
              },
              {
                'id': 'doc_dealer',
                'title': 'Dealer Manual',
                'document_type': 'MANUAL',
                'access_level': 'DEALER',
                'is_published': true,
              },
              {
                'id': 'doc_admin',
                'title': 'Admin Blueprint',
                'document_type': 'TECHNICAL_GUIDE',
                'access_level': 'ADMIN',
                'is_published': true,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = DocumentRepository();

      // Guest only sees public documents when filtering authorized
      final guestDocs = await repo.getDocuments(
        role: AppRole.guest,
        onlyAuthorized: true,
      );
      for (final doc in guestDocs) {
        expect(doc.isPublic, isTrue);
      }

      // Dealer sees public + dealer documents
      final dealerDocs = await repo.getDocuments(
        role: AppRole.dealer,
        onlyAuthorized: true,
      );
      expect(dealerDocs.length, greaterThan(guestDocs.length));
      final hasDealerDoc = dealerDocs.any((d) => d.accessLevel == DocumentAccessLevel.dealer);
      expect(hasDealerDoc, isTrue);

      // Admin sees all documents
      final adminDocs = await repo.getDocuments(
        role: AppRole.admin,
        onlyAuthorized: true,
      );
      expect(adminDocs.length, greaterThanOrEqualTo(dealerDocs.length));
    });

    test('BookmarkRepository toggles and syncs bookmarks', () async {
      ApiClient().setClientForTesting(MockHttpClient((request) async {
        if (request.url.path == '/api/v1/bookmarks') {
          return http.Response(
            jsonEncode({'success': true, 'data': {'id': 'bm_1'}}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.startsWith('/api/v1/bookmarks/sync')) {
          return http.Response(
            jsonEncode({'success': true, 'data': {'synced': 2}}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path.startsWith('/api/v1/bookmarks/')) {
          return http.Response(
            jsonEncode({'success': true}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({'success': true, 'data': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }));

      final repo = BookmarkRepository();

      // Toggle bookmarks
      await repo.toggleBookmark('p001');
      await repo.toggleBookmark('p002');
      expect(repo.isBookmarked('p001'), isTrue);
      expect(repo.isBookmarked('p002'), isTrue);

      // Sync bookmarks
      await repo.syncBookmarks({'p003', 'p004'});
      expect(repo.isBookmarked('p003'), isTrue);
      expect(repo.isBookmarked('p004'), isTrue);
      expect(repo.isBookmarked('p001'), isTrue);
    });
  });
}
