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

/// Authenticated user for session + role shell.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.displayNameAr,
    this.employeeNumber,
    this.departmentId,
    this.departmentNameEn,
    this.departmentNameAr,
    this.managerId,
    this.permissions = const [],
  });

  final String id;
  final String email;
  final String displayName;
  final String? displayNameAr;
  final AppRole role;
  final String? employeeNumber;
  final String? departmentId;
  final String? departmentNameEn;
  final String? departmentNameAr;
  final String? managerId;
  final List<String> permissions;

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

  bool hasPermission(String permission) => permissions.contains(permission);

  String localizedName({required bool arabic}) {
    if (arabic && displayNameAr != null && displayNameAr!.isNotEmpty) {
      return displayNameAr!;
    }
    return displayName;
  }

  String? localizedDepartment({required bool arabic}) {
    if (arabic && departmentNameAr != null && departmentNameAr!.isNotEmpty) {
      return departmentNameAr;
    }
    if (departmentNameEn != null && departmentNameEn!.isNotEmpty) {
      return departmentNameEn;
    }
    return null;
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = AppRole.tryParse(json['role']?.toString()) ?? AppRole.employee;
    final department = json['department'];
    String? departmentId = json['departmentId']?.toString();
    String? departmentNameEn = json['departmentNameEn']?.toString();
    String? departmentNameAr = json['departmentNameAr']?.toString();
    if (department is Map<String, dynamic>) {
      departmentId ??= department['id']?.toString();
      departmentNameEn ??= department['nameEn']?.toString();
      departmentNameAr ??= department['nameAr']?.toString();
    }

    final permissionsRaw = json['permissions'];
    final permissions = permissionsRaw is List
        ? permissionsRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final fullNameEn = json['fullNameEn']?.toString();
    final fullNameAr = json['fullNameAr']?.toString();

    return AppUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          fullNameEn ??
          json['name']?.toString() ??
          json['email']?.toString() ??
          '',
      displayNameAr: fullNameAr,
      role: role,
      employeeNumber: json['employeeNumber']?.toString(),
      departmentId: departmentId,
      departmentNameEn: departmentNameEn,
      departmentNameAr: departmentNameAr,
      managerId: json['managerId']?.toString(),
      permissions: permissions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'fullNameEn': displayName,
        'fullNameAr': displayNameAr,
        'role': role.apiValue,
        'employeeNumber': employeeNumber,
        'departmentId': departmentId,
        'departmentNameEn': departmentNameEn,
        'departmentNameAr': departmentNameAr,
        'managerId': managerId,
        'permissions': permissions,
      };
}
