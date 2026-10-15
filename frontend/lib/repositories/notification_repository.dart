import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../data/mock_data.dart' as mock;
import '../models/notification.dart';

/// Exception thrown when a notification or device operation fails.
class NotificationException implements Exception {
  final String message;
  final int statusCode;
  final bool isNetworkError;

  const NotificationException(this.message, {this.statusCode = 500, this.isNetworkError = false});

  @override
  String toString() => message;
}

/// Notification and Device Registration Data Access Repository.
///
/// Backend endpoints:
/// - GET  /api/v1/notifications
/// - POST /api/v1/devices
/// - POST /api/v1/admin/notifications/send
class NotificationRepository {
  static const String readNotificationIdsKey = 'camso_read_notification_ids';

  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final List<AppNotification> _cachedNotifications = <AppNotification>[];

  /// Fetch public notification broadcast feed with persisted read states.
  Future<List<AppNotification>> getNotifications({int page = 1, int pageSize = 50}) async {
    final res = await _apiClient.get(
      '/notifications',
      queryParams: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    if (res.isSuccess) {
      final items = res.data is List
          ? res.data as List
          : (res.data is Map && (res.data as Map)['data'] is List)
              ? (res.data as Map)['data'] as List
              : (res.data is Map && (res.data as Map)['items'] is List)
                  ? (res.data as Map)['items'] as List
                  : [];

      Set<String> readIds = <String>{};
      try {
        final prefs = await SharedPreferences.getInstance();
        readIds = prefs.getStringList(readNotificationIdsKey)?.toSet() ?? <String>{};
      } catch (_) {}

      final list = items
          .map((item) {
            final n = AppNotification.fromJson(item as Map<String, dynamic>);
            if (readIds.contains(n.id)) {
              return n.copyWith(isRead: true);
            }
            return n;
          })
          .toList();

      _cachedNotifications.clear();
      _cachedNotifications.addAll(list);
      return list;
    }

    if (res.statusCode == 0) {
      throw const NotificationException('Network connection failed. Could not load notifications.',
          statusCode: 0, isNetworkError: true);
    }

    throw NotificationException(
      res.errorMessage ?? 'Failed to load notifications (${res.statusCode}).',
      statusCode: res.statusCode,
    );
  }

  /// Mark single notification as read and persist to storage.
  Future<void> markAsRead(String id) async {
    final index = _cachedNotifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _cachedNotifications[index] = _cachedNotifications[index].copyWith(isRead: true);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(readNotificationIdsKey)?.toSet() ?? <String>{};
      readIds.add(id);
      await prefs.setStringList(readNotificationIdsKey, readIds.toList());
    } catch (_) {}
  }

  /// Mark all notifications as read and persist to storage.
  Future<void> markAllAsRead() async {
    final ids = <String>[];
    for (int i = 0; i < _cachedNotifications.length; i++) {
      _cachedNotifications[i] = _cachedNotifications[i].copyWith(isRead: true);
      ids.add(_cachedNotifications[i].id);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = prefs.getStringList(readNotificationIdsKey)?.toSet() ?? <String>{};
      readIds.addAll(ids);
      await prefs.setStringList(readNotificationIdsKey, readIds.toList());
    } catch (_) {}
  }

  /// Register device token with backend (/api/v1/devices).
  ///
  /// Rejects unsupported platforms (Web/Desktop) or empty device IDs without fake success.
  Future<bool> registerDevice({
    required String deviceId,
    required String platform,
    String? fcmToken,
    String? appVersion,
  }) async {
    final cleanId = deviceId.trim();
    if (cleanId.isEmpty) return false;

    final platUpper = platform.toUpperCase() == 'IOS' ? 'IOS' : 'ANDROID';

    final body = <String, dynamic>{
      'device_id': cleanId,
      'platform': platUpper,
    };
    if (fcmToken != null && fcmToken.trim().isNotEmpty) {
      body['fcm_token'] = fcmToken.trim();
    }
    if (appVersion != null && appVersion.trim().isNotEmpty) {
      body['app_version'] = appVersion.trim();
    }

    try {
      final res = await _apiClient.post('/devices', body: body);
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  /// Get product updates and announcements.
  Future<List<Map<String, dynamic>>> getProductUpdates() async {
    try {
      final list = await getNotifications();
      final updates = list
          .where((n) => n.type.contains('PRODUCT') || n.type.contains('CATALOGUE') || n.type == 'UPDATE')
          .map((n) => <String, dynamic>{
                'id': n.id,
                'title': n.title,
                'summary': n.body,
                'tag': n.type,
                'tagColor': '0xFF203F99',
                'date': n.date,
              })
          .toList();

      if (updates.isNotEmpty) return updates;
    } catch (_) {}

    return List<Map<String, dynamic>>.from(mock.productUpdates);
  }

  /// Add notification (admin or local).
  Future<AppNotification> addNotification(AppNotification notification) async {
    String notifType = 'PROMOTION';
    final upper = notification.type.toUpperCase();
    if (upper.contains('DISCONTINUE')) {
      notifType = 'DISCONTINUED';
    } else if (upper.contains('LAUNCH') || upper.contains('NEW') || upper.contains('PROD') || upper.contains('CATALOGUE')) {
      notifType = 'NEW_LAUNCH';
    } else {
      notifType = 'PROMOTION';
    }

    final res = await _apiClient.post('/admin/notifications', body: {
      'notification_type': notifType,
      if (notification.productId != null && notification.productId!.isNotEmpty)
        'product_id': notification.productId,
      'translations': [
        {
          'language_code': 'en',
          'field': 'title',
          'value': notification.title,
        },
        {
          'language_code': 'en',
          'field': 'body',
          'value': notification.body,
        },
      ],
    });

    if (!res.isSuccess) {
      throw NotificationException(
        res.errorMessage ?? 'Failed to create notification on backend.',
        statusCode: res.statusCode,
      );
    }

    final createdId = (res.data is Map && res.data['id'] != null)
        ? res.data['id'].toString()
        : notification.id;

    final createdNotification = notification.copyWith(id: createdId);
    _cachedNotifications.insert(0, createdNotification);
    return createdNotification;
  }

  /// Update existing notification via PATCH /api/v1/admin/notifications/:id.
  Future<AppNotification> updateNotification(AppNotification notification) async {
    if (notification.id.isEmpty) {
      throw const NotificationException(
        'Cannot update notification without a valid backend ID.',
        statusCode: 400,
      );
    }

    final res = await _apiClient.patch('/admin/notifications/${notification.id}', body: {
      'translations': [
        {
          'language_code': 'en',
          'field': 'title',
          'value': notification.title,
        },
        {
          'language_code': 'en',
          'field': 'body',
          'value': notification.body,
        },
      ],
    });

    if (!res.isSuccess) {
      throw NotificationException(
        res.errorMessage ?? 'Failed to update notification on backend.',
        statusCode: res.statusCode,
      );
    }

    final index = _cachedNotifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _cachedNotifications[index] = notification;
    }
    return notification;
  }

  /// Dispatch broadcast push notification via /admin/notifications/send.
  Future<Map<String, dynamic>> sendBroadcastNotification({
    required String title,
    required String body,
    String targetType = 'ALL_USERS',
  }) async {
    final res = await _apiClient.post('/admin/notifications/send', body: {
      'title': title,
      'body': body,
      'target_type': targetType,
    });

    if (!res.isSuccess) {
      throw NotificationException(
        res.errorMessage ?? 'Failed to dispatch broadcast notification.',
        statusCode: res.statusCode,
      );
    }

    return (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};
  }

  /// Delete notification.
  /// Backend does not register DELETE /api/v1/admin/notifications/:id.
  /// Notifications are immutable broadcast records.
  Future<void> deleteNotification(String id) async {
    throw const NotificationException(
      'Notification deletion is not supported. Broadcast notifications are immutable audit records.',
      statusCode: 405,
    );
  }

  /// Add product update.
  Future<void> addProductUpdate(Map<String, dynamic> update) async {
    final res = await _apiClient.post('/admin/notifications', body: {
      'notification_type': 'NEW_LAUNCH',
      'translations': [
        {
          'language_code': 'en',
          'field': 'title',
          'value': update['title'] ?? 'Product Update',
        },
        {
          'language_code': 'en',
          'field': 'body',
          'value': update['summary'] ?? '',
        },
      ],
    });

    if (!res.isSuccess) {
      throw NotificationException(
        res.errorMessage ?? 'Failed to create product update.',
        statusCode: res.statusCode,
      );
    }
  }

  /// Update product update.
  Future<void> updateProductUpdate(Map<String, dynamic> update) async {
    final id = update['id'];
    if (id == null || id.toString().isEmpty) {
      throw const NotificationException(
        'Cannot update product update without valid ID.',
        statusCode: 400,
      );
    }

    final res = await _apiClient.patch('/admin/notifications/$id', body: {
      'translations': [
        if (update['title'] != null)
          {
            'language_code': 'en',
            'field': 'title',
            'value': update['title'],
          },
        if (update['summary'] != null)
          {
            'language_code': 'en',
            'field': 'body',
            'value': update['summary'],
          },
      ],
    });

    if (!res.isSuccess) {
      throw NotificationException(
        res.errorMessage ?? 'Failed to update product update.',
        statusCode: res.statusCode,
      );
    }
  }

  /// Delete product update.
  Future<void> deleteProductUpdate(String id) async {
    throw const NotificationException(
      'Product update deletion is not supported. Notification updates are immutable audit records.',
      statusCode: 405,
    );
  }

  /// Isolated demo notifications for offline unit tests.
  List<AppNotification> getDemoNotifications() {
    return List<AppNotification>.from(mock.notifications);
  }
}


