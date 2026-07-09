import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';

class ReferenceDepartment {
  const ReferenceDepartment({
    required this.id,
    required this.code,
    required this.nameEn,
    this.nameAr,
  });

  final String id;
  final String code;
  final String nameEn;
  final String? nameAr;

  String localizedName({required bool arabic}) {
    if (arabic && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return nameEn;
  }

  factory ReferenceDepartment.fromJson(Map<String, dynamic> json) {
    return ReferenceDepartment(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
    );
  }
}

class ReferenceCatalog {
  const ReferenceCatalog({
    required this.departments,
    required this.roles,
    required this.notificationPriorities,
  });

  final List<ReferenceDepartment> departments;
  final List<String> roles;
  final List<String> notificationPriorities;

  factory ReferenceCatalog.fromJson(Map<String, dynamic> json) {
    final departmentsRaw = json['departments'];
    final rolesRaw = json['roles'];
    final prioritiesRaw = json['notificationPriorities'];
    return ReferenceCatalog(
      departments: departmentsRaw is List
          ? departmentsRaw
              .whereType<Map<String, dynamic>>()
              .map(ReferenceDepartment.fromJson)
              .toList(growable: false)
          : const [],
      roles: rolesRaw is List
          ? rolesRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
      notificationPriorities: prioritiesRaw is List
          ? prioritiesRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

abstract class ReferenceDataRepository {
  Future<ReferenceCatalog> fetchCatalog();
}

class ApiReferenceDataRepository implements ReferenceDataRepository {
  ApiReferenceDataRepository(this._api);

  final ApiClient _api;

  @override
  Future<ReferenceCatalog> fetchCatalog() async {
    final response = await _api.get<Map<String, dynamic>>('/reference-data');
    final data = response.data;
    if (data == null) {
      throw ApiError.unknown('Empty /reference-data response');
    }
    // Envelope may wrap catalog under data, or return catalog fields at root
    // when already unwrapped in tests.
    if (data['data'] is Map<String, dynamic>) {
      return ReferenceCatalog.fromJson(unwrapDataMap(data));
    }
    if (data.containsKey('departments')) {
      return ReferenceCatalog.fromJson(data);
    }
    return ReferenceCatalog.fromJson(unwrapDataMap(data));
  }
}
