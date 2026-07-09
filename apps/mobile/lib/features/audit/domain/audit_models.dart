/// Domain models for GET /audit-logs.
library;

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.actorId,
    this.actorEmail,
    this.entityId,
    this.metadata,
    this.ipAddress,
    this.userAgent,
  });

  final String id;
  final String? actorId;
  final String? actorEmail;
  final String action;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? metadata;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String? ?? '',
      actorId: json['actorId'] as String?,
      actorEmail: json['actorEmail'] as String?,
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String?,
      metadata: _asStringKeyedMap(json['metadata']),
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Short summary from common metadata keys for list cards.
  String? get summary {
    final meta = metadata;
    if (meta == null || meta.isEmpty) return null;
    for (final key in const [
      'requestNumber',
      'email',
      'recipientCount',
      'priority',
      'audienceType',
      'comment',
      'error',
      'fusionMode',
      'externalFusionRequestId',
    ]) {
      final value = meta[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty) continue;
      return '$key: $text';
    }
    return null;
  }
}

class AuditListResult {
  const AuditListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    this.totalPages = 0,
  });

  final List<AuditLogEntry> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  bool get hasMore {
    if (totalPages > 0) return page < totalPages;
    return page * pageSize < total;
  }
}

class AuditListQuery {
  const AuditListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.actorEmail,
    this.action,
    this.entityType,
    this.from,
    this.to,
  });

  final int page;
  final int pageSize;
  final String? actorEmail;
  final String? action;
  final String? entityType;
  final DateTime? from;
  final DateTime? to;

  AuditListQuery copyWith({
    int? page,
    int? pageSize,
    String? actorEmail,
    String? action,
    String? entityType,
    DateTime? from,
    DateTime? to,
    bool clearActorEmail = false,
    bool clearAction = false,
    bool clearEntityType = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return AuditListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      actorEmail: clearActorEmail ? null : (actorEmail ?? this.actorEmail),
      action: clearAction ? null : (action ?? this.action),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
    );
  }

  bool get hasActiveFilters =>
      (actorEmail != null && actorEmail!.trim().isNotEmpty) ||
      (action != null && action!.isNotEmpty) ||
      (entityType != null && entityType!.isNotEmpty) ||
      from != null ||
      to != null;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (actorEmail != null && actorEmail!.trim().isNotEmpty)
        'actorEmail': actorEmail!.trim(),
      if (action != null && action!.isNotEmpty) 'action': action,
      if (entityType != null && entityType!.isNotEmpty)
        'entityType': entityType,
      if (from != null) 'from': from!.toUtc().toIso8601String(),
      if (to != null) 'to': to!.toUtc().toIso8601String(),
    };
  }
}

/// Known audit actions for filter dropdowns (matches API AuditActions).
abstract final class AuditActionCodes {
  static const authLogin = 'AUTH_LOGIN';
  static const authLogout = 'AUTH_LOGOUT';
  static const notificationCreated = 'NOTIFICATION_CREATED';
  static const notificationPublished = 'NOTIFICATION_PUBLISHED';
  static const notificationRead = 'NOTIFICATION_READ';
  static const notificationCancelled = 'NOTIFICATION_CANCELLED';
  static const accessRequestSubmitted = 'ACCESS_REQUEST_SUBMITTED';
  static const accessRequestCancelled = 'ACCESS_REQUEST_CANCELLED';
  static const accessRequestProvisioningStarted =
      'ACCESS_REQUEST_PROVISIONING_STARTED';
  static const accessRequestCompleted = 'ACCESS_REQUEST_COMPLETED';
  static const accessRequestFailed = 'ACCESS_REQUEST_FAILED';
  static const approvalManagerApproved = 'APPROVAL_MANAGER_APPROVED';
  static const approvalManagerRejected = 'APPROVAL_MANAGER_REJECTED';
  static const approvalSecurityApproved = 'APPROVAL_SECURITY_APPROVED';
  static const approvalSecurityRejected = 'APPROVAL_SECURITY_REJECTED';

  static const List<String> all = [
    authLogin,
    authLogout,
    notificationCreated,
    notificationPublished,
    notificationRead,
    notificationCancelled,
    accessRequestSubmitted,
    accessRequestCancelled,
    accessRequestProvisioningStarted,
    accessRequestCompleted,
    accessRequestFailed,
    approvalManagerApproved,
    approvalManagerRejected,
    approvalSecurityApproved,
    approvalSecurityRejected,
  ];
}

/// Known entity types for filter dropdowns.
abstract final class AuditEntityTypes {
  static const user = 'User';
  static const notification = 'Notification';
  static const accessRequest = 'AccessRequest';
  static const approvalTask = 'ApprovalTask';

  static const List<String> all = [
    user,
    notification,
    accessRequest,
    approvalTask,
  ];
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
