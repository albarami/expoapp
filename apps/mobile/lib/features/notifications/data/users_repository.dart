import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';

/// Active user entry from `GET /users` (admin audience picker, docs 10 + 19).
class AudienceUser {
  const AudienceUser({
    required this.id,
    required this.email,
    required this.fullNameEn,
    this.fullNameAr,
    this.employeeNumber,
    this.departmentCode,
  });

  final String id;
  final String email;
  final String fullNameEn;
  final String? fullNameAr;
  final String? employeeNumber;
  final String? departmentCode;

  String localizedName({required bool arabic}) {
    if (arabic && fullNameAr != null && fullNameAr!.isNotEmpty) {
      return fullNameAr!;
    }
    return fullNameEn;
  }

  factory AudienceUser.fromJson(Map<String, dynamic> json) {
    final department = json['department'];
    return AudienceUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullNameEn: json['fullNameEn']?.toString() ?? '',
      fullNameAr: json['fullNameAr']?.toString(),
      employeeNumber: json['employeeNumber']?.toString(),
      departmentCode: department is Map<String, dynamic>
          ? department['code']?.toString()
          : null,
    );
  }
}

class UserListResult {
  const UserListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<AudienceUser> items;
  final int page;
  final int pageSize;
  final int total;
}

/// `GET /users` API surface (SYSTEM_ADMIN / SECURITY_ADMIN).
abstract class UsersRepository {
  Future<UserListResult> search({
    String? query,
    int page = 1,
    int pageSize = 50,
  });
}

class ApiUsersRepository implements UsersRepository {
  ApiUsersRepository(this._api);

  final ApiClient _api;

  @override
  Future<UserListResult> search({
    String? query,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/users',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (query != null && query.trim().isNotEmpty) 'search': query.trim(),
      },
    );
    final body = response.data;
    if (body == null) {
      throw ApiError.unknown('Empty /users response');
    }

    final items = unwrapDataList(body)
        .whereType<Map<String, dynamic>>()
        .map(AudienceUser.fromJson)
        .toList(growable: false);
    final pagination = unwrapPagination(body);

    return UserListResult(
      items: items,
      page: (pagination?['page'] as num?)?.toInt() ?? page,
      pageSize: (pagination?['pageSize'] as num?)?.toInt() ?? pageSize,
      total: (pagination?['total'] as num?)?.toInt() ?? items.length,
    );
  }
}
