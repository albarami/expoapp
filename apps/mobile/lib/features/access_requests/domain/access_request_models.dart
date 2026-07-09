/// Domain models for access requests (API-aligned).
library;

const minJustificationLength = 20;
const maxJustificationLength = 1000;

enum AccessDuration {
  temporary,
  permanent;

  static AccessDuration? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'TEMPORARY':
        return AccessDuration.temporary;
      case 'PERMANENT':
        return AccessDuration.permanent;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AccessDuration.temporary:
        return 'TEMPORARY';
      case AccessDuration.permanent:
        return 'PERMANENT';
    }
  }
}

enum AccessUrgency {
  normal,
  urgent,
  critical;

  static AccessUrgency? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'NORMAL':
        return AccessUrgency.normal;
      case 'URGENT':
        return AccessUrgency.urgent;
      case 'CRITICAL':
        return AccessUrgency.critical;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AccessUrgency.normal:
        return 'NORMAL';
      case AccessUrgency.urgent:
        return 'URGENT';
      case AccessUrgency.critical:
        return 'CRITICAL';
    }
  }
}

enum AccessRequestStage {
  requester,
  manager,
  security,
  provisioning,
  complete;

  static AccessRequestStage? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'REQUESTER':
        return AccessRequestStage.requester;
      case 'MANAGER':
        return AccessRequestStage.manager;
      case 'SECURITY':
        return AccessRequestStage.security;
      case 'PROVISIONING':
        return AccessRequestStage.provisioning;
      case 'COMPLETE':
        return AccessRequestStage.complete;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AccessRequestStage.requester:
        return 'REQUESTER';
      case AccessRequestStage.manager:
        return 'MANAGER';
      case AccessRequestStage.security:
        return 'SECURITY';
      case AccessRequestStage.provisioning:
        return 'PROVISIONING';
      case AccessRequestStage.complete:
        return 'COMPLETE';
    }
  }
}

/// Status tab filters for My Requests (client-side grouping).
enum AccessRequestListTab {
  all,
  pending,
  completed,
  rejected;

  /// Statuses that belong to this tab when filtering client-side.
  /// When [all], returns null (no status filter).
  List<String>? get statusApiValues {
    switch (this) {
      case AccessRequestListTab.all:
        return null;
      case AccessRequestListTab.pending:
        return const [
          'DRAFT',
          'SUBMITTED',
          'MANAGER_PENDING',
          'MANAGER_APPROVED',
          'SECURITY_PENDING',
          'SECURITY_APPROVED',
          'PROVISIONING',
        ];
      case AccessRequestListTab.completed:
        return const ['COMPLETED'];
      case AccessRequestListTab.rejected:
        return const [
          'MANAGER_REJECTED',
          'SECURITY_REJECTED',
          'CANCELLED',
          'FAILED',
        ];
    }
  }

  bool matches(String status) {
    final values = statusApiValues;
    if (values == null) return true;
    return values.contains(status.toUpperCase());
  }
}

const cancelableStatuses = {'MANAGER_PENDING', 'SECURITY_PENDING'};

class NamedRef {
  const NamedRef({
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

  factory NamedRef.fromJson(Map<String, dynamic> json) {
    return NamedRef(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
    );
  }
}

class PersonRef {
  const PersonRef({
    required this.id,
    required this.fullNameEn,
    this.fullNameAr,
    this.email,
  });

  final String id;
  final String fullNameEn;
  final String? fullNameAr;
  final String? email;

  String localizedName({required bool arabic}) {
    if (arabic && fullNameAr != null && fullNameAr!.isNotEmpty) {
      return fullNameAr!;
    }
    return fullNameEn;
  }

  factory PersonRef.fromJson(Map<String, dynamic> json) {
    return PersonRef(
      id: json['id']?.toString() ?? '',
      fullNameEn: json['fullNameEn']?.toString() ?? '',
      fullNameAr: json['fullNameAr']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class AccessRequestListItem {
  const AccessRequestListItem({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.currentStage,
    required this.urgency,
    required this.accessDuration,
    required this.system,
    required this.securityRole,
    required this.requester,
    this.submittedAt,
    required this.createdAt,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String currentStage;
  final String urgency;
  final String accessDuration;
  final NamedRef system;
  final NamedRef securityRole;
  final PersonRef requester;
  final DateTime? submittedAt;
  final DateTime createdAt;

  bool get isCancelable => cancelableStatuses.contains(status.toUpperCase());

  factory AccessRequestListItem.fromJson(Map<String, dynamic> json) {
    return AccessRequestListItem(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      accessDuration: json['accessDuration']?.toString() ?? 'TEMPORARY',
      system: NamedRef.fromJson(
        (json['system'] as Map<String, dynamic>?) ?? const {},
      ),
      securityRole: NamedRef.fromJson(
        (json['securityRole'] as Map<String, dynamic>?) ?? const {},
      ),
      requester: PersonRef.fromJson(
        (json['requester'] as Map<String, dynamic>?) ?? const {},
      ),
      submittedAt: _parseDate(json['submittedAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class AccessRequestListResult {
  const AccessRequestListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<AccessRequestListItem> items;
  final int page;
  final int pageSize;
  final int total;
}

class AccessRequestTimelineEvent {
  const AccessRequestTimelineEvent({
    required this.id,
    required this.eventType,
    required this.messageEn,
    this.messageAr,
    this.actor,
    required this.createdAt,
  });

  final String id;
  final String eventType;
  final String messageEn;
  final String? messageAr;
  final PersonRef? actor;
  final DateTime createdAt;

  String localizedMessage({required bool arabic}) {
    if (arabic && messageAr != null && messageAr!.isNotEmpty) return messageAr!;
    return messageEn;
  }

  factory AccessRequestTimelineEvent.fromJson(Map<String, dynamic> json) {
    final actorRaw = json['actor'];
    return AccessRequestTimelineEvent(
      id: json['id']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      messageEn: json['messageEn']?.toString() ?? '',
      messageAr: json['messageAr']?.toString(),
      actor: actorRaw is Map<String, dynamic>
          ? PersonRef.fromJson(actorRaw)
          : null,
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class SecurityRoleDetail extends NamedRef {
  const SecurityRoleDetail({
    required super.id,
    required super.code,
    required super.nameEn,
    super.nameAr,
    this.requiresManagerApproval = true,
    this.requiresSecurityApproval = true,
    this.riskLevel,
  });

  final bool requiresManagerApproval;
  final bool requiresSecurityApproval;
  final String? riskLevel;

  factory SecurityRoleDetail.fromJson(Map<String, dynamic> json) {
    return SecurityRoleDetail(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString(),
      requiresManagerApproval: json['requiresManagerApproval'] == true,
      requiresSecurityApproval: json['requiresSecurityApproval'] == true,
      riskLevel: json['riskLevel']?.toString(),
    );
  }
}

class AccessRequestDetail {
  const AccessRequestDetail({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.currentStage,
    required this.businessJustification,
    required this.accessDuration,
    required this.urgency,
    this.startDate,
    this.endDate,
    this.submittedAt,
    this.completedAt,
    this.externalFusionRequestId,
    required this.system,
    required this.securityRole,
    required this.requester,
    this.nextApprover,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String currentStage;
  final String businessJustification;
  final String accessDuration;
  final String urgency;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? submittedAt;
  final DateTime? completedAt;
  final String? externalFusionRequestId;
  final NamedRef system;
  final SecurityRoleDetail securityRole;
  final PersonRef requester;
  final PersonRef? nextApprover;
  final List<AccessRequestTimelineEvent> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCancelable => cancelableStatuses.contains(status.toUpperCase());

  AccessRequestDetail copyWithId({
    String? id,
    String? requestNumber,
    String? status,
  }) {
    return AccessRequestDetail(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      status: status ?? this.status,
      currentStage: currentStage,
      businessJustification: businessJustification,
      accessDuration: accessDuration,
      urgency: urgency,
      startDate: startDate,
      endDate: endDate,
      submittedAt: submittedAt,
      completedAt: completedAt,
      externalFusionRequestId: externalFusionRequestId,
      system: system,
      securityRole: securityRole,
      requester: requester,
      nextApprover: nextApprover,
      timeline: timeline,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AccessRequestDetail.fromJson(Map<String, dynamic> json) {
    final timelineRaw = json['timeline'];
    final nextRaw = json['nextApprover'];
    return AccessRequestDetail(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
      businessJustification: json['businessJustification']?.toString() ?? '',
      accessDuration: json['accessDuration']?.toString() ?? 'TEMPORARY',
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      submittedAt: _parseDate(json['submittedAt']),
      completedAt: _parseDate(json['completedAt']),
      externalFusionRequestId: json['externalFusionRequestId']?.toString(),
      system: NamedRef.fromJson(
        (json['system'] as Map<String, dynamic>?) ?? const {},
      ),
      securityRole: SecurityRoleDetail.fromJson(
        (json['securityRole'] as Map<String, dynamic>?) ?? const {},
      ),
      requester: PersonRef.fromJson(
        (json['requester'] as Map<String, dynamic>?) ?? const {},
      ),
      nextApprover: nextRaw is Map<String, dynamic>
          ? PersonRef.fromJson(nextRaw)
          : null,
      timeline: timelineRaw is List
          ? timelineRaw
              .whereType<Map<String, dynamic>>()
              .map(AccessRequestTimelineEvent.fromJson)
              .toList(growable: false)
          : const [],
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(json['updatedAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class SubmitAccessRequestResult {
  const SubmitAccessRequestResult({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.currentStage,
    this.nextApprover,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String currentStage;
  final PersonRef? nextApprover;

  factory SubmitAccessRequestResult.fromJson(Map<String, dynamic> json) {
    final nextRaw = json['nextApprover'];
    return SubmitAccessRequestResult(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
      nextApprover: nextRaw is Map<String, dynamic>
          ? PersonRef.fromJson(nextRaw)
          : null,
    );
  }
}

class CancelAccessRequestResult {
  const CancelAccessRequestResult({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.currentStage,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String currentStage;

  factory CancelAccessRequestResult.fromJson(Map<String, dynamic> json) {
    return CancelAccessRequestResult(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
    );
  }
}

class CreateAccessRequestPayload {
  const CreateAccessRequestPayload({
    required this.systemId,
    required this.securityRoleId,
    required this.businessJustification,
    required this.accessDuration,
    required this.startDate,
    this.endDate,
    required this.urgency,
  });

  final String systemId;
  final String securityRoleId;
  final String businessJustification;
  final AccessDuration accessDuration;
  final DateTime startDate;
  final DateTime? endDate;
  final AccessUrgency urgency;

  Map<String, dynamic> toJson() {
    return {
      'systemId': systemId,
      'securityRoleId': securityRoleId,
      'businessJustification': businessJustification,
      'accessDuration': accessDuration.apiValue,
      'startDate': startDate.toUtc().toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toUtc().toIso8601String(),
      'urgency': urgency.apiValue,
    };
  }
}

class AccessRequestListQuery {
  const AccessRequestListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.urgency,
    this.systemId,
    this.requesterId,
  });

  final int page;
  final int pageSize;
  final String? status;
  final String? urgency;
  final String? systemId;
  final String? requesterId;

  AccessRequestListQuery copyWith({
    int? page,
    int? pageSize,
    String? status,
    String? urgency,
    String? systemId,
    String? requesterId,
    bool clearStatus = false,
    bool clearUrgency = false,
    bool clearSystemId = false,
    bool clearRequesterId = false,
  }) {
    return AccessRequestListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: clearStatus ? null : (status ?? this.status),
      urgency: clearUrgency ? null : (urgency ?? this.urgency),
      systemId: clearSystemId ? null : (systemId ?? this.systemId),
      requesterId: clearRequesterId ? null : (requesterId ?? this.requesterId),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (urgency != null && urgency!.isNotEmpty) 'urgency': urgency,
      if (systemId != null && systemId!.isNotEmpty) 'systemId': systemId,
      if (requesterId != null && requesterId!.isNotEmpty)
        'requesterId': requesterId,
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
