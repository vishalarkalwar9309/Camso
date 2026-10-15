/// The six roles supported by the CAMSO frontend.
///
/// This is a frontend role model only. Real permissions must be verified by
/// the backend when a separate developer integrates authentication.
enum AppRole {
  guest,
  dealer,
  distributor,
  admin,
  employee,
  oemPartner,
}

extension AppRoleDetails on AppRole {
  String get id {
    switch (this) {
      case AppRole.guest:
        return 'guest';
      case AppRole.dealer:
        return 'dealer';
      case AppRole.distributor:
        return 'distributor';
      case AppRole.admin:
        return 'admin';
      case AppRole.employee:
        return 'employee';
      case AppRole.oemPartner:
        return 'oem';
    }
  }

  String get label {
    switch (this) {
      case AppRole.guest:
        return 'Guest';
      case AppRole.dealer:
        return 'Dealer';
      case AppRole.distributor:
        return 'Distributor';
      case AppRole.admin:
        return 'Admin';
      case AppRole.employee:
        return 'Employee';
      case AppRole.oemPartner:
        return 'OEM Partner';
    }
  }

  static AppRole fromId(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'dealer':
        return AppRole.dealer;
      case 'distributor':
        return AppRole.distributor;
      case 'admin':
        return AppRole.admin;
      case 'employee':
      case 'ceat employee':
        return AppRole.employee;
      case 'oem':
      case 'oem_partner':
      case 'oem partner':
        return AppRole.oemPartner;
      case 'guest':
      case 'other':
      case 'other / end user':
      default:
        return AppRole.guest;
    }
  }
}
