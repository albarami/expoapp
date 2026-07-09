/// Notification priority matching Prisma `NotificationPriority`.
enum AppNotificationPriority {
  low,
  normal,
  high,
  critical;

  static AppNotificationPriority? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'LOW':
        return AppNotificationPriority.low;
      case 'NORMAL':
        return AppNotificationPriority.normal;
      case 'HIGH':
        return AppNotificationPriority.high;
      case 'CRITICAL':
      case 'URGENT': // legacy alias used in early Flutter stubs
        return AppNotificationPriority.critical;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AppNotificationPriority.low:
        return 'LOW';
      case AppNotificationPriority.normal:
        return 'NORMAL';
      case AppNotificationPriority.high:
        return 'HIGH';
      case AppNotificationPriority.critical:
        return 'CRITICAL';
    }
  }
}

/// Audience type matching Prisma `AudienceType`.
enum AppAudienceType {
  all,
  department,
  role,
  users;

  static AppAudienceType? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'ALL':
        return AppAudienceType.all;
      case 'DEPARTMENT':
        return AppAudienceType.department;
      case 'ROLE':
        return AppAudienceType.role;
      case 'USERS':
        return AppAudienceType.users;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case AppAudienceType.all:
        return 'ALL';
      case AppAudienceType.department:
        return 'DEPARTMENT';
      case AppAudienceType.role:
        return 'ROLE';
      case AppAudienceType.users:
        return 'USERS';
    }
  }
}

/// List/detail notification item from `/notifications`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.titleEn,
    required this.bodyEn,
    required this.priority,
    required this.status,
    required this.audienceType,
    required this.createdAt,
    this.titleAr,
    this.bodyAr,
    this.readAt,
    this.audienceFilter,
    this.publishAt,
    this.expiresAt,
    this.deliveredAt,
  });

  final String id;
  final String titleEn;
  final String? titleAr;
  final String bodyEn;
  final String? bodyAr;
  final String priority;
  final String status;
  final String audienceType;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? audienceFilter;
  final DateTime? publishAt;
  final DateTime? expiresAt;
  final DateTime? deliveredAt;

  bool get isUnread => readAt == null;

  AppNotificationPriority get priorityEnum =>
      AppNotificationPriority.tryParse(priority) ??
      AppNotificationPriority.normal;

  AppAudienceType get audienceTypeEnum =>
      AppAudienceType.tryParse(audienceType) ?? AppAudienceType.all;

  String localizedTitle({required bool arabic}) {
    if (arabic && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return titleEn;
  }

  String localizedBody({required bool arabic}) {
    if (arabic && bodyAr != null && bodyAr!.isNotEmpty) {
      return bodyAr!;
    }
    return bodyEn;
  }

  String bodyPreview({required bool arabic, int maxLength = 120}) {
    final body = localizedBody(arabic: arabic).trim();
    if (body.length <= maxLength) return body;
    return '${body.substring(0, maxLength).trimRight()}…';
  }

  AppNotification copyWith({DateTime? readAt}) {
    return AppNotification(
      id: id,
      titleEn: titleEn,
      titleAr: titleAr,
      bodyEn: bodyEn,
      bodyAr: bodyAr,
      priority: priority,
      status: status,
      audienceType: audienceType,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      audienceFilter: audienceFilter,
      publishAt: publishAt,
      expiresAt: expiresAt,
      deliveredAt: deliveredAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final filter = json['audienceFilter'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      titleAr: json['titleAr']?.toString(),
      bodyEn: json['bodyEn']?.toString() ?? '',
      bodyAr: json['bodyAr']?.toString(),
      priority: json['priority']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'PUBLISHED',
      audienceType: json['audienceType']?.toString() ?? 'ALL',
      readAt: _parseDate(json['readAt']),
      createdAt:
          _parseDate(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      audienceFilter: filter is Map<String, dynamic> ? filter : null,
      publishAt: _parseDate(json['publishAt']),
      expiresAt: _parseDate(json['expiresAt']),
      deliveredAt: _parseDate(json['deliveredAt']),
    );
  }
}

class NotificationStats {
  const NotificationStats({
    required this.notificationId,
    required this.recipientCount,
    required this.deliveredCount,
    required this.readCount,
    required this.unreadCount,
    required this.readPercentage,
  });

  final String notificationId;
  final int recipientCount;
  final int deliveredCount;
  final int readCount;
  final int unreadCount;
  final double readPercentage;

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      notificationId: json['notificationId']?.toString() ?? '',
      recipientCount: _asInt(json['recipientCount']),
      deliveredCount: _asInt(json['deliveredCount']),
      readCount: _asInt(json['readCount']),
      unreadCount: _asInt(json['unreadCount']),
      readPercentage: _asDouble(json['readPercentage']),
    );
  }
}

class CreateNotificationResult {
  const CreateNotificationResult({
    required this.id,
    required this.status,
    required this.recipientCount,
  });

  final String id;
  final String status;
  final int recipientCount;

  factory CreateNotificationResult.fromJson(Map<String, dynamic> json) {
    return CreateNotificationResult(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      recipientCount: _asInt(json['recipientCount']),
    );
  }
}

class CreateNotificationRequest {
  const CreateNotificationRequest({
    required this.titleEn,
    required this.bodyEn,
    required this.priority,
    required this.audienceType,
    required this.audienceFilter,
    this.titleAr,
    this.bodyAr,
    this.publishNow = true,
    this.publishAt,
    this.expiresAt,
  });

  final String titleEn;
  final String? titleAr;
  final String bodyEn;
  final String? bodyAr;
  final AppNotificationPriority priority;
  final AppAudienceType audienceType;
  final Map<String, dynamic> audienceFilter;
  final bool publishNow;
  final DateTime? publishAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'titleEn': titleEn,
      if (titleAr != null && titleAr!.trim().isNotEmpty) 'titleAr': titleAr,
      'bodyEn': bodyEn,
      if (bodyAr != null && bodyAr!.trim().isNotEmpty) 'bodyAr': bodyAr,
      'priority': priority.apiValue,
      'audienceType': audienceType.apiValue,
      'audienceFilter': audienceFilter,
      'publishNow': publishNow,
      if (!publishNow && publishAt != null)
        'publishAt': publishAt!.toUtc().toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toUtc().toIso8601String(),
    };
  }
}

/// List query filters for `GET /notifications`.
class NotificationListQuery {
  const NotificationListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.unreadOnly,
    this.priority,
    this.search,
  });

  final int page;
  final int pageSize;
  final bool? unreadOnly;
  final AppNotificationPriority? priority;
  final String? search;

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (unreadOnly != null) 'unreadOnly': unreadOnly,
      if (priority != null) 'priority': priority!.apiValue,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    };
  }

  NotificationListQuery copyWith({
    int? page,
    int? pageSize,
    bool? unreadOnly,
    AppNotificationPriority? priority,
    String? search,
    bool clearUnreadOnly = false,
    bool clearPriority = false,
    bool clearSearch = false,
  }) {
    return NotificationListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      unreadOnly: clearUnreadOnly ? null : (unreadOnly ?? this.unreadOnly),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationListQuery &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.unreadOnly == unreadOnly &&
        other.priority == priority &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(page, pageSize, unreadOnly, priority, search);
}

class NotificationListResult {
  const NotificationListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<AppNotification> items;
  final int page;
  final int pageSize;
  final int total;

  bool get hasMore => page * pageSize < total;
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

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
