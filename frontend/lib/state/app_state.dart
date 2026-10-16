import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/auth_service.dart';
import '../core/auth/auth_session.dart';
import '../core/localization/app_strings.dart';
import '../core/permissions/permission_service.dart';
import '../data/mock_data.dart';
import '../models/app_role.dart';
import '../models/document.dart';
import '../models/notification.dart';
import '../models/product.dart';
import '../repositories/bookmark_repository.dart';
import '../repositories/document_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/search_repository.dart';
import '../repositories/content_repository.dart';

/// Central application state manager.
///
/// Unifies authentication session, role-based permissions, and data repositories.
/// Ready for backend integration via the [AuthService] and repositories.
class AppState extends ChangeNotifier {
  AppState() {
    _init();
  }

  // --- Services and Repositories ---
  final AuthService authService = AuthService();
  final ProductRepository productRepository = ProductRepository();
  final DocumentRepository documentRepository = DocumentRepository();
  final NotificationRepository notificationRepository = NotificationRepository();
  final SearchRepository searchRepository = SearchRepository();
  final BookmarkRepository bookmarkRepository = BookmarkRepository();
  final ContentRepository contentRepository = ContentRepository();

  // --- State Variables ---
  static const String languageKey = 'camso_app_language';
  static const List<String> supportedLanguages = ['en', 'fr', 'de', 'it'];

  int tab = 0;
  String language = 'en';
  bool _initialized = false;
  bool get isInitialized => _initialized;

  static String normalizeLanguage(String? code) {
    if (code == null || code.trim().isEmpty) return 'en';
    final lower = code.trim().toLowerCase();
    if (supportedLanguages.contains(lower)) {
      return lower;
    }
    final prefix = lower.split(RegExp(r'[-_]')).first;
    if (supportedLanguages.contains(prefix)) {
      return prefix;
    }
    return 'en';
  }

  AuthSession? _session;
  AuthSession? get session => _session;

  AppRole get role => _session?.role ?? AppRole.guest;
  bool get loggedIn => _session != null && !_session!.isGuest;
  String get businessRole => role.id;
  String get roleLabel => role.label;
  String get userDisplayName => _session?.displayName ?? (loggedIn ? 'User' : 'Guest');
  String? get userEmail => _session?.email;
  String? get organizationName => _session?.organizationName;

  PermissionService get permissions => PermissionService(role);

  final Set<String> bookmarks = <String>{};
  final List<String> recent = List<String>.from(recentSearches);
  late List<AppNotification> notificationItems = List<AppNotification>.from(notifications);
  late List<Document> documentItems = List<Document>.from(documents);
  late List<Product> productItems = List<Product>.from(products);
  late List<Map<String, dynamic>> categoryItems = List<Map<String, dynamic>>.from(categories);

  int get unreadCount => notificationItems.where((n) => !n.isRead).length;

  Future<void> _init() async {
    // Restore saved language preference
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(languageKey);
      if (savedLang != null && savedLang.isNotEmpty) {
        language = normalizeLanguage(savedLang);
      }
    } catch (_) {}

    final restored = await authService.restoreSession();
    if (restored != null) {
      _session = restored;
    } else {
      _session = AuthSession.guest();
    }

    // Attempt live bootstrap without blocking startup
    try {
      final ids = await bookmarkRepository.getBookmarks();
      bookmarks.clear();
      bookmarks.addAll(ids);
    } catch (_) {}

    try {
      final notifs = await notificationRepository.getNotifications();
      if (notifs.isNotEmpty) {
        notificationItems = notifs;
      }
    } catch (_) {}

    try {
      final docs = await documentRepository.getDocuments();
      if (docs.isNotEmpty) {
        documentItems = docs;
      }
    } catch (_) {}

    try {
      final prods = await productRepository.getProducts(pageSize: 100);
      if (prods.isNotEmpty) {
        productItems = prods;
      }
    } catch (_) {}

    try {
      final cats = await productRepository.getCategories();
      if (cats.isNotEmpty) {
        categoryItems = cats;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString(AuthService.guestDeviceIdKey) ?? _session?.userId;
      if (deviceId != null && deviceId.isNotEmpty) {
        await notificationRepository.registerDevice(
          deviceId: deviceId,
          platform: 'ANDROID',
          appVersion: '1.0.0',
        );
      }
    } catch (_) {}

    _initialized = true;
    notifyListeners();
  }


  void setTab(int value) {
    if (value < 0 || value > 4 || tab == value) return;
    tab = value;
    notifyListeners();
  }

  void setLanguage(String code) {
    final normalized = normalizeLanguage(code);
    if (language == normalized) return;
    language = normalized;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(languageKey, normalized);
    }).catchError((_) {});
  }

  /// Translate a key based on current active language.
  String tr(String key) => AppStrings.tr(key, language);

  // --- Authentication Actions ---

  /// Sign in with specific role and credentials.
  Future<void> signIn({
    required String email,
    required String password,
    required AppRole role,
  }) async {
    // Collect any existing guest bookmarks to synchronize
    final guestBookmarks = Set<String>.from(bookmarks);

    final session = await authService.login(
      email: email,
      password: password,
      role: role,
    );
    _session = session;

    // Synchronize bookmarks from guest session to account
    if (guestBookmarks.isNotEmpty) {
      await bookmarkRepository.syncBookmarks(guestBookmarks);
      bookmarks.addAll(guestBookmarks);
    }

    notifyListeners();
  }

  /// One-click quick demo sign in for testing any of the 6 roles.
  Future<void> signInAsDemo(AppRole role) async {
    final guestBookmarks = Set<String>.from(bookmarks);

    final session = await authService.loginAsDemoRole(role);
    _session = session;

    if (guestBookmarks.isNotEmpty) {
      await bookmarkRepository.syncBookmarks(guestBookmarks);
      bookmarks.addAll(guestBookmarks);
    }

    notifyListeners();
  }

  /// Start or reset to guest session.
  Future<void> continueAsGuest() async {
    final session = await authService.startGuestSession();
    _session = session;
    notifyListeners();
  }

  /// Sign out and return to Guest session.
  Future<void> signOut() async {
    await authService.logout();
    _session = AuthSession.guest();
    tab = 0;
    notifyListeners();
  }

  /// Accepts role ID or name for backwards compatibility with existing screens.
  void setBusinessRole(String value) {
    final nextRole = AppRoleDetails.fromId(value);
    signInAsDemo(nextRole);
  }

  /// Backwards compatibility setter.
  void setLoggedIn(bool value) {
    if (!value) {
      signOut();
    }
  }

  // --- Bookmark Management ---

  bool toggleBookmark(String id) {
    if (!loggedIn) {
      return false;
    }
    if (bookmarks.contains(id)) {
      bookmarks.remove(id);
    } else {
      bookmarks.add(id);
    }
    bookmarkRepository.toggleBookmark(id);
    notifyListeners();
    return true;
  }

  bool isBookmarked(String id) => bookmarks.contains(id);

  // --- Recent Searches ---

  void addRecent(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    recent.removeWhere((x) => x.toLowerCase() == v.toLowerCase());
    recent.insert(0, v);
    if (recent.length > 6) recent.removeLast();
    searchRepository.addRecentSearch(v);
    notifyListeners();
  }

  void clearRecent() {
    recent.clear();
    searchRepository.clearRecentSearches();
    notifyListeners();
  }

  // --- Document Management & Role Filtering ---

  /// Get documents visible to the current role.
  List<Document> getVisibleDocuments({String? category, String? query}) {
    return documentItems.where((doc) {
      if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
        if (doc.category.toLowerCase() != category.toLowerCase()) return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final match = doc.title.toLowerCase().contains(q) ||
            doc.type.toLowerCase().contains(q) ||
            doc.description.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  Future<void> refreshDocuments() async {
    try {
      final docs = await documentRepository.getDocuments(pageSize: 100);
      if (docs.isNotEmpty) {
        documentItems = docs;
        notifyListeners();
      }
    } catch (_) {}
  }

  void mergeDocuments(List<Document> newDocs) {
    if (newDocs.isEmpty) return;
    final Map<String, Document> map = {
      for (final d in documentItems) d.id: d,
    };
    for (final d in newDocs) {
      map[d.id] = d;
    }
    documentItems = map.values.toList();
    notifyListeners();
  }

  Future<Document> addDocument(Document doc) async {
    final created = await documentRepository.addDocument(doc);
    documentItems = [created, ...documentItems.where((d) => d.id != created.id)];
    notifyListeners();
    await refreshDocuments();
    return created;
  }

  Future<void> updateDocument(Document doc) async {
    documentItems = [
      for (final item in documentItems) item.id == doc.id ? doc : item,
    ];
    notifyListeners();
    await documentRepository.updateDocument(doc);
    await refreshDocuments();
  }

  Future<void> removeDocument(String id) async {
    documentItems = documentItems.where((d) => d.id != id).toList();
    notifyListeners();
    await documentRepository.deleteDocument(id);
    await refreshDocuments();
  }

  // --- Product Management ---

  Future<void> refreshProducts() async {
    try {
      final prods = await productRepository.getProducts(pageSize: 100);
      if (prods.isNotEmpty) {
        productItems = prods;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Product> addProduct(Product product) async {
    final created = await productRepository.addProduct(product);
    productItems = [created, ...productItems.where((p) => p.id != created.id)];
    notifyListeners();
    await refreshProducts();
    return created;
  }

  Future<void> updateProduct(Product product) async {
    productItems = [
      for (final p in productItems) p.id == product.id ? product : p,
    ];
    notifyListeners();
    await productRepository.updateProduct(product);
    await refreshProducts();
  }

  Future<void> removeProduct(String id) async {
    productItems = productItems.where((p) => p.id != id).toList();
    notifyListeners();
    await productRepository.deleteProduct(id);
    await refreshProducts();
  }

  // --- Category Management ---

  Future<void> refreshCategories() async {
    try {
      final cats = await productRepository.getCategories();
      if (cats.isNotEmpty) {
        categoryItems = cats;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>> addCategory(Map<String, dynamic> category) async {
    final created = await productRepository.addCategory(category);
    categoryItems = [created, ...categoryItems.where((c) => c['id'] != created['id'])];
    notifyListeners();
    await refreshCategories();
    return created;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> category) async {
    await productRepository.updateCategory(id, category);
    await refreshCategories();
  }

  Future<void> removeCategory(String id) async {
    categoryItems = categoryItems.where((c) => c['id'] != id).toList();
    notifyListeners();
    await productRepository.deleteCategory(id);
    await refreshCategories();
  }

  // --- Notifications ---

  Future<AppNotification> addNotification(AppNotification notification) async {
    final created = await notificationRepository.addNotification(notification);
    notificationItems = [created, ...notificationItems.where((n) => n.id != created.id)];
    notifyListeners();
    await refreshNotifications();
    return created;
  }

  Future<void> updateNotification(AppNotification notification) async {
    await notificationRepository.updateNotification(notification);
    notificationItems = [
      for (final item in notificationItems)
        item.id == notification.id ? notification : item,
    ];
    notifyListeners();
    await refreshNotifications();
  }

  void replaceNotification(String id, AppNotification replacement) {
    notificationItems = [
      for (final item in notificationItems)
        item.id == id ? replacement : item,
    ];
    notifyListeners();
  }

  Future<void> removeNotification(String id) async {
    await notificationRepository.deleteNotification(id);
    notificationItems = notificationItems.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void markRead(String id) {
    notificationItems = [
      for (final n in notificationItems)
        n.id == id ? n.copyWith(isRead: true) : n,
    ];
    notificationRepository.markAsRead(id);
    notifyListeners();
  }

  void markAllRead() {
    notificationItems = [
      for (final n in notificationItems) n.copyWith(isRead: true),
    ];
    notificationRepository.markAllAsRead();
    notifyListeners();
  }

  Future<void> refreshNotifications() async {
    try {
      final notifs = await notificationRepository.getNotifications();
      notificationItems = notifs;
      notifyListeners();
    } catch (_) {}
  }

  void notifyMockDataChanged() => notifyListeners();
}
