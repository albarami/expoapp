import '../../access_requests/domain/access_request_models.dart';

/// Max comment length aligned with API `MAX_APPROVAL_COMMENT_LENGTH`.
const maxApprovalCommentLength = 1000;

/// Approval task decision values from the API.
enum ApprovalDecision {
  pending,
  approved,
  rejected,
  returned;

  static ApprovalDecision? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return ApprovalDecision.pending;
      case 'APPROVED':
        return ApprovalDecision.approved;
      case 'REJECTED':
        return ApprovalDecision.rejected;
      case 'RETURNED':
        return ApprovalDecision.returned;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case ApprovalDecision.pending:
        return 'PENDING';
      case ApprovalDecision.approved:
        return 'APPROVED';
      case ApprovalDecision.rejected:
        return 'REJECTED';
      case ApprovalDecision.returned:
        return 'RETURNED';
    }
  }
}

/// Approval workflow stage on the task.
enum ApprovalStage {
  manager,
  security;

  static ApprovalStage? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'MANAGER':
        return ApprovalStage.manager;
      case 'SECURITY':
        return ApprovalStage.security;
      default:
        return null;
    }
  }

  String get apiValue {
    switch (this) {
      case ApprovalStage.manager:
        return 'MANAGER';
      case ApprovalStage.security:
        return 'SECURITY';
    }
  }
}

/// Queue tab: Pending vs Completed (approved/rejected).
enum ApprovalQueueTab {
  pending,
  completed;

  String? get statusApiValue {
    switch (this) {
      case ApprovalQueueTab.pending:
        return 'PENDING';
      case ApprovalQueueTab.completed:
        // API filters by a single decision; completed is client-side
        // (APPROVED + REJECTED). We fetch without status and filter locally,
        // or fetch twice — prefer no status filter + client filter for
        // completed, and status=PENDING for pending.
        return null;
    }
  }
}

/// Nested access-request summary on an approval list/detail item.
class ApprovalAccessRequestSummary {
  const ApprovalAccessRequestSummary({
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
  });

  final String id;
  final String requestNumber;
  final String status;
  final String currentStage;
  final String urgency;
  final String accessDuration;
  final NamedRef system;
  final SecurityRoleDetail securityRole;
  final PersonRef requester;
  final DateTime? submittedAt;

  factory ApprovalAccessRequestSummary.fromJson(Map<String, dynamic> json) {
    return ApprovalAccessRequestSummary(
      id: json['id']?.toString() ?? '',
      requestNumber: json['requestNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? 'NORMAL',
      accessDuration: json['accessDuration']?.toString() ?? 'TEMPORARY',
      system: NamedRef.fromJson(
        (json['system'] as Map<String, dynamic>?) ?? const {},
      ),
      securityRole: SecurityRoleDetail.fromJson(
        (json['securityRole'] as Map<String, dynamic>?) ?? const {},
      ),
      requester: PersonRef.fromJson(
        (json['requester'] as Map<String, dynamic>?) ?? const {},
      ),
      submittedAt: _parseDate(json['submittedAt']),
    );
  }
}

class ApprovalTask {
  const ApprovalTask({
    required this.id,
    required this.stage,
    required this.decision,
    this.comment,
    this.decidedAt,
    required this.createdAt,
    required this.accessRequest,
  });

  final String id;
  final String stage;
  final String decision;
  final String? comment;
  final DateTime? decidedAt;
  final DateTime createdAt;
  final ApprovalAccessRequestSummary accessRequest;

  bool get isPending => decision.toUpperCase() == 'PENDING';

  factory ApprovalTask.fromJson(Map<String, dynamic> json) {
    return ApprovalTask(
      id: json['id']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      decision: json['decision']?.toString() ?? 'PENDING',
      comment: json['comment']?.toString(),
      decidedAt: _parseDate(json['decidedAt']),
      createdAt: _parseDate(json['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      accessRequest: ApprovalAccessRequestSummary.fromJson(
        (json['accessRequest'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}

class ApprovalListResult {
  const ApprovalListResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<ApprovalTask> items;
  final int page;
  final int pageSize;
  final int total;
}

enum ApprovalDecisionInput {
  approved,
  rejected;

  String get apiValue {
    switch (this) {
      case ApprovalDecisionInput.approved:
        return 'APPROVED';
      case ApprovalDecisionInput.rejected:
        return 'REJECTED';
    }
  }
}

class DecideApprovalPayload {
  const DecideApprovalPayload({
    required this.decision,
    this.comment,
  });

  final ApprovalDecisionInput decision;
  final String? comment;

  Map<String, dynamic> toJson() {
    return {
      'decision': decision.apiValue,
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
    };
  }
}

class DecideApprovalResult {
  const DecideApprovalResult({
    required this.taskId,
    required this.decision,
    required this.requestId,
    required this.requestNumber,
    required this.status,
    required this.currentStage,
  });

  final String taskId;
  final String decision;
  final String requestId;
  final String requestNumber;
  final String status;
  final String currentStage;

  factory DecideApprovalResult.fromJson(Map<String, dynamic> json) {
    final request = json['request'] as Map<String, dynamic>? ?? const {};
    return DecideApprovalResult(
      taskId: json['taskId']?.toString() ?? '',
      decision: json['decision']?.toString() ?? '',
      requestId: request['id']?.toString() ?? '',
      requestNumber: request['requestNumber']?.toString() ?? '',
      status: request['status']?.toString() ?? '',
      currentStage: request['currentStage']?.toString() ?? '',
    );
  }
}

class ApprovalListQuery {
  const ApprovalListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.status,
  });

  final int page;
  final int pageSize;
  final String? status;

  ApprovalListQuery copyWith({
    int? page,
    int? pageSize,
    String? status,
    bool clearStatus = false,
  }) {
    return ApprovalListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: clearStatus ? null : (status ?? this.status),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'pageSize': pageSize,
      if (status != null && status!.isNotEmpty) 'status': status,
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
