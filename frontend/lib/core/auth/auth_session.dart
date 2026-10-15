import 'dart:convert';
import '../../models/app_role.dart';

/// User identity and session model.
///
/// Designed to align with the backend's JWT authentication responses across
/// Customer Auth (/auth), Business Auth (/business-auth), and Admin Auth (/admin-auth).
class AuthSession {
  final String userId;
  final String? email;
  final String displayName;
  final AppRole role;
  final String? organizationName;
  final String? organizationCode;
  final String? accessToken;
  final String? refreshToken;
  final bool isGuest;
  final String? phone;
  final String preferredLanguage;

  const AuthSession({
    required this.userId,
    this.email,
    required this.displayName,
    required this.role,
    this.organizationName,
    this.organizationCode,
    this.accessToken,
    this.refreshToken,
    this.isGuest = false,
    this.phone,
    this.preferredLanguage = 'en',
  });

  /// Factory for a local or backend guest session (/auth/guest).
  factory AuthSession.guest({String? deviceId}) {
    final id = deviceId ?? 'guest-client-${DateTime.now().millisecondsSinceEpoch}';
    return AuthSession(
      userId: id,
      email: null,
      displayName: 'Guest User',
      role: AppRole.guest,
      organizationName: null,
      accessToken: 'mock_guest_token_$id',
      refreshToken: null,
      isGuest: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'role': role.id,
        'organizationName': organizationName,
        'organizationCode': organizationCode,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'isGuest': isGuest,
        'phone': phone,
        'preferredLanguage': preferredLanguage,
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] as String? ?? 'guest',
      email: json['email'] as String?,
      displayName: json['displayName'] as String? ?? 'User',
      role: AppRoleDetails.fromId(json['role'] as String?),
      organizationName: json['organizationName'] as String?,
      organizationCode: json['organizationCode'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      phone: json['phone'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }

  String serialize() => jsonEncode(toJson());

  static AuthSession? deserialize(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
