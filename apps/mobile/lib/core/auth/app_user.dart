/// Application roles matching backend RBAC.
enum AppRole {
  employee,
  manager,
  securityAdmin,
  systemAdmin;

  static AppRole? tryParse(String? value) {
    switch (value) {
      case 'EMPLOYEE':
        return AppRole.employee;
      case 'MANAGER':
        return AppRole.manager;
      case 'SECURITY_ADMIN':
        return AppRole.securityAdmin;
      case 'SYSTEM_ADMIN':
        return AppRole.systemAdmin;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AppRole.employee:
        return 'EMPLOYEE';
      case AppRole.manager:
        return 'MANAGER';
      case AppRole.securityAdmin:
        return 'SECURITY_ADMIN';
      case AppRole.systemAdmin:
        return 'SYSTEM_ADMIN';
    }
  }
}

/// Minimal authenticated user for session + shell.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.departmentId,
    this.managerId,
  });

  final String id;
  final String email;
  final String displayName;
  final AppRole role;
  final String? departmentId;
  final String? managerId;

  bool get isEmployee => role == AppRole.employee;
  bool get isManager => role == AppRole.manager;
  bool get isSecurityAdmin => role == AppRole.securityAdmin;
  bool get isSystemAdmin => role == AppRole.systemAdmin;

  bool get canApprove =>
      role == AppRole.manager ||
      role == AppRole.securityAdmin ||
      role == AppRole.systemAdmin;

  bool get canViewAudit =>
      role == AppRole.securityAdmin || role == AppRole.systemAdmin;

  bool get canCreateNotification =>
      role == AppRole.systemAdmin || role == AppRole.securityAdmin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = AppRole.tryParse(json['role']?.toString()) ?? AppRole.employee;
    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          json['name']?.toString() ??
          json['email']?.toString() ??
          '',
      role: role,
      departmentId: json['departmentId']?.toString(),
      managerId: json['managerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role.apiValue,
        'departmentId': departmentId,
        'managerId': managerId,
      };
}
