import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';
import '../domain/access_request_models.dart';

/// System + security-role catalog from `/reference-data`.
class AccessReferenceSystem {
  const AccessReferenceSystem({
    required this.id,
    required this.code,
    required this.nameEn,
    this.nameAr,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String code;
  final String nameEn;
  final String? nameAr;
  final String? description;
  final bool isActive;

  String localizedName({required bool arabic}) {
    if (arabic && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return nameEn;
  }

  factory AccessReferenceSystem.fromJson(Map<String, dynamic> json) {
    return AccessReferenceSystem(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
      description: json['description']?.toString(),
      isActive: json['isActive'] != false,
    );
  }
}

class AccessReferenceSecurityRole {
  const AccessReferenceSecurityRole({
    required this.id,
    required this.systemId,
    required this.systemCode,
    required this.code,
    required this.nameEn,
    this.nameAr,
    this.description,
    this.riskLevel,
    this.requiresManagerApproval = true,
    this.requiresSecurityApproval = true,
    this.isActive = true,
  });

  final String id;
  final String systemId;
  final String systemCode;
  final String code;
  final String nameEn;
  final String? nameAr;
  final String? description;
  final String? riskLevel;
  final bool requiresManagerApproval;
  final bool requiresSecurityApproval;
  final bool isActive;

  String localizedName({required bool arabic}) {
    if (arabic && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return nameEn;
  }

  factory AccessReferenceSecurityRole.fromJson(Map<String, dynamic> json) {
    return AccessReferenceSecurityRole(
      id: json['id']?.toString() ?? '',
      systemId: json['systemId']?.toString() ?? '',
      systemCode: json['systemCode']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
      description: json['description']?.toString(),
      riskLevel: json['riskLevel']?.toString(),
      requiresManagerApproval: json['requiresManagerApproval'] != false,
      requiresSecurityApproval: json['requiresSecurityApproval'] != false,
      isActive: json['isActive'] != false,
    );
  }
}

class AccessReferenceCatalog {
  const AccessReferenceCatalog({
    required this.systems,
    required this.securityRoles,
    required this.accessUrgencies,
    required this.accessDurations,
  });

  final List<AccessReferenceSystem> systems;
  final List<AccessReferenceSecurityRole> securityRoles;
  final List<String> accessUrgencies;
  final List<String> accessDurations;

  List<AccessReferenceSystem> get activeSystems =>
      systems.where((s) => s.isActive).toList(growable: false);

  List<AccessReferenceSecurityRole> rolesForSystem(String systemId) {
    return securityRoles
        .where((r) => r.isActive && r.systemId == systemId)
        .toList(growable: false);
  }

  factory AccessReferenceCatalog.fromJson(Map<String, dynamic> json) {
    final systemsRaw = json['systems'];
    final rolesRaw = json['securityRoles'];
    final urgenciesRaw = json['accessUrgencies'];
    final durationsRaw = json['accessDurations'];
    return AccessReferenceCatalog(
      systems: systemsRaw is List
          ? systemsRaw
              .whereType<Map<String, dynamic>>()
              .map(AccessReferenceSystem.fromJson)
              .toList(growable: false)
          : const [],
      securityRoles: rolesRaw is List
          ? rolesRaw
              .whereType<Map<String, dynamic>>()
              .map(AccessReferenceSecurityRole.fromJson)
              .toList(growable: false)
          : const [],
      accessUrgencies: urgenciesRaw is List
          ? urgenciesRaw.map((e) => e.toString()).toList(growable: false)
          : AccessUrgency.values.map((e) => e.apiValue).toList(),
      accessDurations: durationsRaw is List
          ? durationsRaw.map((e) => e.toString()).toList(growable: false)
          : AccessDuration.values.map((e) => e.apiValue).toList(),
    );
  }
}

abstract class AccessReferenceDataRepository {
  Future<AccessReferenceCatalog> fetchCatalog();
}

class ApiAccessReferenceDataRepository
    implements AccessReferenceDataRepository {
  ApiAccessReferenceDataRepository(this._api);

  final ApiClient _api;

  @override
  Future<AccessReferenceCatalog> fetchCatalog() async {
    final response = await _api.get<Map<String, dynamic>>('/reference-data');
    final data = response.data;
    if (data == null) {
      throw ApiError.unknown('Empty /reference-data response');
    }
    if (data['data'] is Map<String, dynamic>) {
      return AccessReferenceCatalog.fromJson(unwrapDataMap(data));
    }
    if (data.containsKey('systems') || data.containsKey('securityRoles')) {
      return AccessReferenceCatalog.fromJson(data);
    }
    return AccessReferenceCatalog.fromJson(unwrapDataMap(data));
  }
}
