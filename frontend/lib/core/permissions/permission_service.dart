import '../../models/app_role.dart';
import '../../models/document.dart';

/// Centralized frontend role and permission service.
///
/// This provides consistent permission checks across screens and components.
/// While this controls visibility and user experience in the Flutter client,
/// server-side JWT authorization guards must be enforced by the backend API.
class PermissionService {
  const PermissionService(this.role);

  final AppRole role;

  bool get isGuest => role == AppRole.guest;
  bool get isAdmin => role == AppRole.admin;
  bool get isEmployee => role == AppRole.employee;
  bool get isDealer => role == AppRole.dealer;
  bool get isDistributor => role == AppRole.distributor;
  bool get isOemPartner => role == AppRole.oemPartner;
  bool get isAuthenticated => !isGuest;

  // Catalogue & Discovery
  bool get canBrowsePublicProducts => true;
  bool get canSearchCatalogue => true;
  bool get canBookmark => true; // Guests can bookmark locally; synced on login

  // Calculators
  bool get canUseCalculators => true;
  bool get canSaveCalculatorResults => isAuthenticated;

  // Documents & Support
  bool get canViewPublicDocuments => true;
  bool get canViewInternalResources => isEmployee || isAdmin;
  bool get canViewOemResources => isOemPartner || isAdmin;
  bool get canViewDealerSupport => isDealer || isAdmin;
  bool get canViewDistributorSupport => isDistributor || isAdmin;

  // Document-specific checks
  bool canViewDocument(Document doc) {
    return doc.accessLevel.isAuthorized(role);
  }

  bool canDownloadDocument(Document doc) {
    if (!canViewDocument(doc)) return false;
    // Public documents can be downloaded; restricted documents require authentication
    if (doc.isPublic) return true;
    return isAuthenticated;
  }

  // Administrative Content Management
  bool get canViewAdminAnalytics => isAdmin;
  bool get canManageProducts => isAdmin;
  bool get canManageCategories => isAdmin;
  bool get canManageDocuments => isAdmin;
  bool get canManageNotifications => isAdmin;
  bool get canManageProductUpdates => isAdmin;
  bool get canManageUsers => false; // Explicitly excluded from scope

  // Role labels and descriptions
  String get roleDisplayName => role.label;
  String get roleIdentifier => role.id;
}
