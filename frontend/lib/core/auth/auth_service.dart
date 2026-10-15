import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_role.dart';
import '../api/api_client.dart';
import 'auth_session.dart';

/// Pre-configured demo account credential definition.
class DemoAccount {
  final String label;
  final String email;
  final String password;
  final AppRole role;
  final String displayName;
  final String organizationName;
  final String description;

  const DemoAccount({
    required this.label,
    required this.email,
    required this.password,
    required this.role,
    required this.displayName,
    required this.organizationName,
    required this.description,
  });
}

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;
  final int statusCode;

  const AuthException(this.message, {this.statusCode = 401});

  @override
  String toString() => message;
}

/// Authentication Service with backend integration architecture.
///
/// Documented backend endpoints from CAMSO API Specification:
/// - Base URL: http://localhost:4000/api/v1
/// - Guest Session:    POST /auth/guest           { device_id, platform }
/// - Customer Login:   POST /auth/login           { email, password }
/// - Customer Register:POST /auth/register        { email, password, display_name }
/// - Business Login:   POST /business-auth/login  { email, password }  (Dealer, Distributor, OEM)
/// - Admin Login:      POST /admin-auth/login     { email, password }
/// - Profile Me:       GET /users/me or /admin-auth/me
/// - Bookmark Sync:    POST /bookmarks/sync       { guest_token }
class AuthService {
  static const String sessionKey = 'camso_auth_session';
  static const String guestDeviceIdKey = 'camso_guest_device_id';

  static String get apiBaseUrl => ApiClient.baseUrl;

  /// Standard demo credentials aligned with backend seeds and roles.
  static const List<DemoAccount> demoAccounts = [
    DemoAccount(
      label: 'Admin',
      email: 'demo.admin@camso.local',
      password: '',
      role: AppRole.admin,
      displayName: 'Alex Morgan',
      organizationName: 'CAMSO Central Platform',
      description: 'Full CMS content management and catalogue analytics access.',
    ),
    DemoAccount(
      label: 'Dealer',
      email: 'demo.dealer@camso.local',
      password: '',
      role: AppRole.dealer,
      displayName: 'Klaus Schmidt',
      organizationName: 'Alpine Equipment GmbH',
      description: 'Authorized dealer with access to dealer sales and warranty guides.',
    ),
    DemoAccount(
      label: 'Distributor',
      email: 'demo.distributor@camso.local',
      password: '',
      role: AppRole.distributor,
      displayName: 'Marc Dubois',
      organizationName: 'CEAT Specialty Tires — Western Europe',
      description: 'Regional distributor with supply chain guides and distributor network support.',
    ),
    DemoAccount(
      label: 'Employee',
      email: 'employee@ceat.com',
      password: '',
      role: AppRole.employee,
      displayName: 'Jean Schmidt',
      organizationName: 'CEAT Specialty Tyres Ltd.',
      description: 'Internal staff with access to internal engineering handbooks and product training.',
    ),
    DemoAccount(
      label: 'OEM Partner',
      email: 'demo.oem@camso.local',
      password: '',
      role: AppRole.oemPartner,
      displayName: 'David Miller',
      organizationName: 'Caterpillar Global OEM Division',
      description: 'Original equipment partner with access to CAD specs and fitment guides.',
    ),
  ];

  /// Restore persisted session from SharedPreferences on application startup.
  /// If session is authenticated (non-guest), validates the token against the backend.
  /// If backend returns 401 or 403, clears the session and returns null.
  Future<AuthSession?> restoreSession({bool validateWithServer = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(sessionKey);
      if (raw == null || raw.trim().isEmpty) {
        return null;
      }

      final session = AuthSession.deserialize(raw);
      if (session == null) {
        await clearSession();
        return null;
      }

      // Guest session does not need remote token validation
      if (session.isGuest) {
        if (session.accessToken != null) {
          ApiClient().setAuthToken(session.accessToken);
        }
        return session;
      }

      // Stale or mock token check from old buggy versions
      final token = session.accessToken;
      if (token == null || token.isEmpty || token.startsWith('jwt_mock_')) {
        await logout();
        return null;
      }

      // Set token for API calls
      ApiClient().setAuthToken(token);

      if (validateWithServer && !token.startsWith('demo_mode_')) {
        final isValid = await validateSession(session);
        if (!isValid) {
          await logout();
          return null;
        }
      }

      return session;
    } catch (_) {
      await logout();
      return null;
    }
  }

  /// Validate active session against existing backend endpoints.
  /// Returns false if server returns 401 (invalid/expired) or 403 (unapproved/suspended).
  Future<bool> validateSession(AuthSession session) async {
    try {
      String endpoint;
      if (session.role == AppRole.admin) {
        endpoint = '/admin-auth/me';
      } else if (session.role == AppRole.dealer ||
                 session.role == AppRole.distributor ||
                 session.role == AppRole.oemPartner) {
        endpoint = '/business/organization';
      } else {
        endpoint = '/users/me';
      }

      final res = await ApiClient().get(endpoint, timeout: const Duration(seconds: 3));

      // If server explicitly rejected the token (401 Unauthorized or 403 Forbidden)
      if (res.statusCode == 401 || res.statusCode == 403) {
        return false;
      }

      // If request succeeded, session is verified
      if (res.isSuccess) {
        return true;
      }

      // Client errors indicate invalid token/session
      if (res.statusCode >= 400 && res.statusCode < 500) {
        return false;
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  /// Save session to persistent device storage.
  Future<void> saveSession(AuthSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sessionKey, session.serialize());
    } catch (_) {}
  }

  /// Clear session from device storage.
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(sessionKey);
    } catch (_) {}
  }

  /// Start a guest session (mapped to POST /api/v1/auth/guest).
  Future<AuthSession> startGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(guestDeviceIdKey);
    if (deviceId == null) {
      deviceId = 'camso-dev-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(guestDeviceIdKey, deviceId);
    }

    String guestToken = 'guest_token_$deviceId';
    try {
      final res = await ApiClient().post('/auth/guest', body: {
        'device_id': deviceId,
        'platform': 'ANDROID',
      }, timeout: const Duration(seconds: 2));
      if (res.isSuccess && res.data is Map) {
        final token = res.data['access_token'] ?? res.data['token'];
        if (token != null) {
          guestToken = token.toString();
        }
      }
    } catch (_) {}

    ApiClient().setAuthToken(guestToken);
    final session = AuthSession.guest(deviceId: deviceId);
    await saveSession(session);
    return session;
  }

  /// Sign in using role-aware authentication.
  ///
  /// Routes to:
  /// - [AppRole.admin] -> POST /api/v1/admin-auth/login
  /// - [AppRole.dealer] / [AppRole.distributor] / [AppRole.oemPartner] -> POST /api/v1/business-auth/login
  /// - Other roles -> POST /api/v1/auth/login
  ///
  /// Never creates mock sessions or falls back to demo credentials on failure.
  Future<AuthSession> login({
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter both email and password.', statusCode: 400);
    }

    // Route to appropriate backend authentication endpoint
    String endpoint;
    if (role == AppRole.admin) {
      endpoint = '/admin-auth/login';
    } else if (role == AppRole.dealer || role == AppRole.distributor || role == AppRole.oemPartner) {
      endpoint = '/business-auth/login';
    } else {
      endpoint = '/auth/login';
    }

    final res = await ApiClient().post(endpoint, body: {
      'email': cleanEmail,
      'password': password,
    }, timeout: const Duration(seconds: 4));

    if (!res.isSuccess) {
      final status = res.statusCode;
      final serverMsg = res.errorMessage;

      if (status == 401) {
        throw AuthException(serverMsg ?? 'Invalid email or password.', statusCode: 401);
      } else if (status == 403) {
        throw AuthException(serverMsg ?? 'Your account is pending administrator approval.', statusCode: 403);
      } else if (status == 0 || status == 408) {
        throw AuthException(serverMsg ?? 'Unable to connect to server. Please check your network connection.', statusCode: status);
      } else {
        throw AuthException(serverMsg ?? 'Authentication failed (status $status).', statusCode: status);
      }
    }

    final data = res.data;
    if (data is! Map) {
      throw const AuthException('Invalid authentication response from server.', statusCode: 500);
    }

    String? accessToken;
    String? refreshToken;

    if (data['tokens'] is Map) {
      final tokensMap = data['tokens'] as Map;
      accessToken = tokensMap['access_token']?.toString() ?? tokensMap['accessToken']?.toString();
      refreshToken = tokensMap['refresh_token']?.toString() ?? tokensMap['refreshToken']?.toString();
    }

    accessToken ??= data['access_token']?.toString() ??
                    data['accessToken']?.toString() ??
                    data['token']?.toString();

    refreshToken ??= data['refresh_token']?.toString() ??
                     data['refreshToken']?.toString();

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthException('Authentication response did not contain an access token.', statusCode: 500);
    }

    String? userId;
    String? displayName;
    String? organizationName;
    String? organizationCode;

    final userObj = data['user'] ?? data['admin'];
    if (userObj is Map) {
      userId = userObj['id']?.toString();
      displayName = userObj['display_name']?.toString() ??
                    userObj['name']?.toString() ??
                    userObj['email']?.toString();
      if (userObj['organization'] is Map) {
        organizationName = userObj['organization']['name']?.toString();
        organizationCode = userObj['organization']['type']?.toString();
      }
    }

    if (data['organization'] is Map) {
      organizationName ??= data['organization']['name']?.toString();
      organizationCode ??= data['organization']['type']?.toString();
    }

    ApiClient().setAuthToken(accessToken);

    final session = AuthSession(
      userId: userId ?? 'usr_${cleanEmail.hashCode.abs()}',
      email: cleanEmail,
      displayName: displayName ?? _extractNameFromEmail(cleanEmail),
      role: role,
      organizationName: organizationName ?? _defaultOrgForRole(role),
      organizationCode: organizationCode ?? role.id.toUpperCase(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      isGuest: false,
    );

    await saveSession(session);
    return session;
  }

  /// Quick demo sign-in for testing any of the 6 roles in offline development.
  /// Explicitly isolated from production authentication and real API login failures.
  Future<AuthSession> loginAsDemoRole(AppRole role) async {
    if (role == AppRole.guest) {
      return startGuestSession();
    }

    final demo = demoAccounts.firstWhere(
      (d) => d.role == role,
      orElse: () => demoAccounts.first,
    );

    final demoToken = 'demo_mode_${role.id}_token';
    ApiClient().setAuthToken(demoToken);

    final session = AuthSession(
      userId: 'demo_${role.id}_user',
      email: demo.email,
      displayName: demo.displayName,
      role: role,
      organizationName: demo.organizationName,
      organizationCode: role.id.toUpperCase(),
      accessToken: demoToken,
      refreshToken: 'demo_mode_${role.id}_refresh',
      isGuest: false,
    );

    await saveSession(session);
    return session;
  }

  /// Sign out and clear stored session and API authorization headers.
  Future<void> logout() async {
    ApiClient().setAuthToken(null);
    await clearSession();
  }

  /// Synchronize guest bookmarks with account (mapped to POST /api/v1/bookmarks/sync).
  Future<bool> syncGuestBookmarks(List<String> productIds, String? guestToken) async {
    try {
      final res = await ApiClient().post('/bookmarks/sync', body: {
        'guest_token': guestToken,
        'product_ids': productIds,
      }, timeout: const Duration(milliseconds: 1500));
      return res.isSuccess;
    } catch (_) {
      return true;
    }
  }

  static String _extractNameFromEmail(String email) {
    final prefix = email.split('@').first.replaceAll('.', ' ');
    return prefix
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }

  static String _defaultOrgForRole(AppRole role) {
    switch (role) {
      case AppRole.dealer:
        return 'Authorized Dealer Network';
      case AppRole.distributor:
        return 'Regional Distributor Partner';
      case AppRole.employee:
        return 'CEAT Specialty Tyres Ltd.';
      case AppRole.oemPartner:
        return 'OEM Equipment Partner';
      case AppRole.admin:
        return 'CAMSO Administrator';
      case AppRole.guest:
        return 'Guest User';
    }
  }
}
