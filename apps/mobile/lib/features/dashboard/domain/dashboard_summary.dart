import '../../../core/auth/app_user.dart';

/// Notification row from `GET /dashboard/summary`.
class DashboardNotificationItem {
  const DashboardNotificationItem({
    required this.id,
    required this.titleEn,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.titleAr,
    this.readAt,
  });

  final String id;
  final String titleEn;
  final String? titleAr;
  final String priority;
  final String status;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;

  String localizedTitle({required bool arabic}) {
    if (arabic && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return titleEn;
  }

  factory DashboardNotificationItem.fromJson(Map<String, dynamic> json) {
    return DashboardNotificationItem(
      id: json['id']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      titleAr: json['titleAr']?.toString(),
      priority: json['priority']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'PUBLISHED',
      readAt: _parseDate(json['readAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Access-request row from dashboard summary.
class DashboardRequestItem {
  const DashboardRequestItem({
    required this.id,
    required this.requestNumber,
    required this.status,
    required this.urgency,
    required this.systemCode,
    required this.systemNameEn,
    required this.securityRoleCode,
    required this.securityRoleNameEn,
    required this.createdAt,
    this.submittedAt,
  });

  final String id;
  final String requestNumber;
  final String status;
  final String urgency;
  final String systemCode;
  final String systemNameEn;
  final String securityRoleCode;
  final String securityRoleNameEn;
  final DateTime? submittedAt;
  final DateTime createdAt;

  factory DashboardRequestItem.fromJson(Map<String, dynamic> json) {
    return DashboardRequestItem(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      systemCode: json['systemCode']?.toString() ?? '',
      systemNameEn: json['systemNameEn']?.toString() ?? '',
      securityRoleCode: json['securityRoleCode']?.toString() ?? '',
      securityRoleNameEn: json['securityRoleNameEn']?.toString() ?? '',
      submittedAt: _parseDate(json['submittedAt']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Audit row for security/system admin dashboards.
class DashboardAuditItem {
  const DashboardAuditItem({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.entityId,
    this.actorEmail,
  });

  final String id;
  final String action;
  final String entityType;
  final String? entityId;
  final String? actorEmail;
  final DateTime createdAt;

  factory DashboardAuditItem.fromJson(Map<String, dynamic> json) {
    return DashboardAuditItem(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString(),
      actorEmail: json['actorEmail']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class DashboardNotificationStats {
  const DashboardNotificationStats({
    required this.publishedCount,
    required this.recipientCount,
    required this.readCount,
    required this.readPercentage,
  });

  final int publishedCount;
  final int recipientCount;
  final int readCount;
  final int readPercentage;

  factory DashboardNotificationStats.fromJson(Map<String, dynamic> json) {
    return DashboardNotificationStats(
      publishedCount: _asInt(json['publishedCount']),
      recipientCount: _asInt(json['recipientCount']),
      readCount: _asInt(json['readCount']),
      readPercentage: _asInt(json['readPercentage']),
    );
  }
}

class DashboardAccessWorkflowStats {
  const DashboardAccessWorkflowStats({
    required this.openAccessRequests,
    required this.pendingManagerApprovals,
    required this.pendingSecurityApprovals,
    required this.completedRequests,
  });

  final int openAccessRequests;
  final int pendingManagerApprovals;
  final int pendingSecurityApprovals;
  final int completedRequests;

  factory DashboardAccessWorkflowStats.fromJson(Map<String, dynamic> json) {
    return DashboardAccessWorkflowStats(
      openAccessRequests: _asInt(json['openAccessRequests']),
      pendingManagerApprovals: _asInt(json['pendingManagerApprovals']),
      pendingSecurityApprovals: _asInt(json['pendingSecurityApprovals']),
      completedRequests: _asInt(json['completedRequests']),
    );
  }
}

/// Role-aware payload from `GET /dashboard/summary`.
class DashboardSummary {
  const DashboardSummary({
    required this.role,
    required this.unreadNotifications,
    required this.openAccessRequests,
    required this.completedRequests,
    required this.pendingApprovals,
    required this.latestNotifications,
    required this.latestRequests,
    this.teamOpenRequests,
    this.pendingSecurityApprovals,
    this.highRiskOpenRequests,
    this.recentAuditEvents,
    this.notificationStats,
    this.accessWorkflowStats,
  });

  final AppRole role;
  final int unreadNotifications;
  final int openAccessRequests;
  final int completedRequests;
  final int pendingApprovals;
  final List<DashboardNotificationItem> latestNotifications;
  final List<DashboardRequestItem> latestRequests;
  final int? teamOpenRequests;
  final int? pendingSecurityApprovals;
  final int? highRiskOpenRequests;
  final List<DashboardAuditItem>? recentAuditEvents;
  final DashboardNotificationStats? notificationStats;
  final DashboardAccessWorkflowStats? accessWorkflowStats;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      role: AppRole.tryParse(json['role']?.toString()) ?? AppRole.employee,
      unreadNotifications: _asInt(json['unreadNotifications']),
      openAccessRequests: _asInt(json['openAccessRequests']),
      completedRequests: _asInt(json['completedRequests']),
      pendingApprovals: _asInt(json['pendingApprovals']),
      latestNotifications: _mapList(
        json['latestNotifications'],
        DashboardNotificationItem.fromJson,
      ),
      latestRequests: _mapList(
        json['latestRequests'],
        DashboardRequestItem.fromJson,
      ),
      teamOpenRequests: _asNullableInt(json['teamOpenRequests']),
      pendingSecurityApprovals: _asNullableInt(json['pendingSecurityApprovals']),
      highRiskOpenRequests: _asNullableInt(json['highRiskOpenRequests']),
      recentAuditEvents: json['recentAuditEvents'] == null
          ? null
          : _mapList(json['recentAuditEvents'], DashboardAuditItem.fromJson),
      notificationStats: json['notificationStats'] is Map<String, dynamic>
          ? DashboardNotificationStats.fromJson(
              json['notificationStats'] as Map<String, dynamic>,
            )
          : null,
      accessWorkflowStats: json['accessWorkflowStats'] is Map<String, dynamic>
          ? DashboardAccessWorkflowStats.fromJson(
              json['accessWorkflowStats'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(Object? value) {
  if (value == null) return null;
  return _asInt(value);
}

List<T> _mapList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) mapper,
) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(mapper)
      .toList(growable: false);
}
