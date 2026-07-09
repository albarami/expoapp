// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ExpoApp';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get home => 'الرئيسية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get requests => 'الطلبات';

  @override
  String get approvals => 'الموافقات';

  @override
  String get auditLogs => 'سجلات التدقيق';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get newAccessRequest => 'طلب صلاحية جديد';

  @override
  String get createNotification => 'إنشاء إشعار';

  @override
  String get markAsRead => 'تحديد كمقروء';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get cancel => 'إلغاء';

  @override
  String get submit => 'إرسال';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جاري التحميل…';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get foundationPlaceholder =>
      'شاشة أساسية — واجهة الميزة ستأتي في مهمة لاحقة.';

  @override
  String get noNotifications => 'لا توجد إشعارات حتى الآن';

  @override
  String get noNotificationsMessage => 'ستظهر الإعلانات المهمة هنا.';

  @override
  String get noRequests => 'لا توجد طلبات صلاحيات حتى الآن';

  @override
  String get noRequestsMessage => 'أنشئ أول طلب صلاحية أمنية.';

  @override
  String get noApprovals => 'لا توجد موافقات معلقة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get errorGeneric => 'يرجى المحاولة مرة أخرى.';

  @override
  String get unauthorizedTitle => 'الوصول مرفوض';

  @override
  String get unauthorizedMessage => 'ليس لديك صلاحية لعرض هذه الشاشة.';

  @override
  String get networkError =>
      'لا يمكن الاتصال بالخادم. تحقق من الشبكة وحاول مرة أخرى.';

  @override
  String get businessJustification => 'مبرر العمل';

  @override
  String get system => 'النظام';

  @override
  String get securityRole => 'الصلاحية الأمنية';

  @override
  String get duration => 'المدة';

  @override
  String get urgency => 'الأولوية';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get confirm => 'تأكيد';

  @override
  String get demoLoginHint => 'استخدم حساب تجريبي مسجّل لتسجيل الدخول.';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusSubmitted => 'مُرسل';

  @override
  String get statusManagerPending => 'بانتظار المدير';

  @override
  String get statusManagerApproved => 'موافقة المدير';

  @override
  String get statusSecurityPending => 'بانتظار الأمن';

  @override
  String get statusSecurityApproved => 'موافقة الأمن';

  @override
  String get statusProvisioning => 'جاري التنفيذ';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusManagerRejected => 'مرفوض من المدير';

  @override
  String get statusSecurityRejected => 'مرفوض من الأمن';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusFailed => 'فشل';

  @override
  String dashboardGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get dashboardSubtitle => 'نظرة عامة حسب صلاحيتك';

  @override
  String get unreadNotifications => 'إشعارات غير مقروءة';

  @override
  String get openAccessRequests => 'طلبات صلاحية مفتوحة';

  @override
  String get completedRequests => 'طلبات مكتملة';

  @override
  String get pendingApprovals => 'موافقات معلّقة';

  @override
  String get teamOpenRequests => 'طلبات الفريق المفتوحة';

  @override
  String get pendingSecurityApprovals => 'موافقات أمنية معلّقة';

  @override
  String get highRiskOpenRequests => 'طلبات عالية المخاطر';

  @override
  String get publishedNotifications => 'إشعارات منشورة';

  @override
  String get totalRecipients => 'إجمالي المستلمين';

  @override
  String get readCount => 'عدد المقروء';

  @override
  String get readPercentage => 'نسبة القراءة';

  @override
  String get pendingManagerApprovals => 'موافقات المدير المعلّقة';

  @override
  String get latestNotifications => 'أحدث الإشعارات';

  @override
  String get latestRequests => 'أحدث الطلبات';

  @override
  String get recentAuditEvents => 'أحداث التدقيق الأخيرة';

  @override
  String get notificationStats => 'إحصاءات الإشعارات';

  @override
  String get accessWorkflowStats => 'إحصاءات سير طلبات الصلاحية';

  @override
  String get noAuditEvents => 'لا توجد أحداث تدقيق حديثة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get priorityLow => 'منخفضة';

  @override
  String get priorityNormal => 'عادية';

  @override
  String get priorityHigh => 'عالية';

  @override
  String get priorityCritical => 'حرجة';

  @override
  String get priorityUrgent => 'عاجلة';

  @override
  String get searchNotifications => 'البحث في الإشعارات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterUnread => 'غير مقروء';

  @override
  String get unread => 'غير مقروء';

  @override
  String get readStatus => 'مقروء';

  @override
  String notificationsUnreadCount(int count) {
    return '$count غير مقروء في هذه الصفحة';
  }

  @override
  String get notificationDetail => 'الإشعار';

  @override
  String get markedAsRead => 'تم التحديد كمقروء';

  @override
  String get deliveredCount => 'تم التسليم';

  @override
  String get unreadCountLabel => 'مستلمون لم يقرأوا';

  @override
  String get titleEn => 'العنوان (الإنجليزية)';

  @override
  String get titleArOptional => 'العنوان (العربية، اختياري)';

  @override
  String get bodyEn => 'النص (الإنجليزية)';

  @override
  String get bodyArOptional => 'النص (العربية، اختياري)';

  @override
  String get priority => 'الأولوية';

  @override
  String get audienceType => 'الجمهور';

  @override
  String get audienceAll => 'الجميع';

  @override
  String get audienceDepartment => 'الأقسام';

  @override
  String get audienceRole => 'الأدوار';

  @override
  String get audienceUsers => 'مستخدمون محددون';

  @override
  String get audienceAllHint =>
      'سيتم إرسال هذا الإشعار إلى جميع المستخدمين النشطين.';

  @override
  String get audienceUsersUnavailable =>
      'اختيار مستخدمين فرديين غير متاح في هذا الإصدار. اختر الجميع أو القسم أو الدور.';

  @override
  String get publishNow => 'نشر الآن';

  @override
  String get publishNowHint => 'يتم إنشاء المستلمين فوراً.';

  @override
  String get schedulePublishHint => 'جدولة وقت نشر مستقبلي.';

  @override
  String get publishAt => 'وقت النشر';

  @override
  String get expiresAtOptional => 'ينتهي في (اختياري)';

  @override
  String get selectDateTime => 'اختر التاريخ والوقت';

  @override
  String get preview => 'معاينة';

  @override
  String get publish => 'نشر';

  @override
  String get createNotificationSubtitle =>
      'أنشئ إعلاناً ثنائي اللغة للجمهور المحدد.';

  @override
  String get criticalConfirmTitle => 'نشر إشعار حرج؟';

  @override
  String get criticalConfirmMessage =>
      'الإشعارات الحرجة عاجلة. أكّد أنك تريد النشر الآن.';

  @override
  String get notificationCreatedTitle => 'تم إنشاء الإشعار';

  @override
  String notificationCreatedMessage(int count) {
    return 'تم التسليم إلى $count مستلمين.';
  }

  @override
  String get validationRequired => 'هذا الحقل مطلوب.';

  @override
  String validationMinLength(int min) {
    return 'يجب أن يكون على الأقل $min أحرف.';
  }

  @override
  String validationMaxLength(int max) {
    return 'يجب ألا يتجاوز $max أحرف.';
  }

  @override
  String get validationAudienceRequired => 'اختر قيمة جمهور واحدة على الأقل.';

  @override
  String get validationPublishAtRequired => 'اختر وقت النشر عند الجدولة.';

  @override
  String get errorManagerNotFound => 'لم يتم العثور على مدير لهذا الطلب.';

  @override
  String get errorRoleNotRequestable => 'لا يمكن طلب هذه الصلاحية.';

  @override
  String get errorDuplicateActiveRequest =>
      'لديك طلب نشط بالفعل لهذه الصلاحية.';

  @override
  String get errorInvalidAccessDates =>
      'تحقق من تاريخ البداية والنهاية لهذا الطلب.';

  @override
  String get errorRequestNotCancelable => 'لا يمكن إلغاء هذا الطلب بعد الآن.';

  @override
  String get errorUserInactive => 'حسابك غير نشط.';

  @override
  String get errorValidation => 'يرجى التحقق من النموذج والمحاولة مرة أخرى.';

  @override
  String get errorUnauthorized => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get validationEmailRequired => 'البريد الإلكتروني مطلوب.';

  @override
  String get validationEmailInvalid => 'أدخل بريداً إلكترونياً صالحاً.';

  @override
  String get validationPasswordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get demoQuickLogin => 'دخول تجريبي سريع';

  @override
  String get demoEmployee => 'موظف';

  @override
  String get demoManager => 'مدير';

  @override
  String get demoSecurityAdmin => 'مسؤول الأمن';

  @override
  String get demoSystemAdmin => 'مسؤول النظام';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get sessionRestoring => 'جاري استعادة جلستك…';

  @override
  String signedInAs(String name) {
    return 'مسجّل الدخول باسم $name';
  }

  @override
  String get security => 'الأمن';

  @override
  String get create => 'إنشاء';

  @override
  String get filterPending => 'معلّق';

  @override
  String get filterCompleted => 'مكتمل';

  @override
  String get filterRejected => 'مرفوض';

  @override
  String get requestDetail => 'تفاصيل الطلب';

  @override
  String get requester => 'مقدّم الطلب';

  @override
  String get riskLevel => 'مستوى المخاطر';

  @override
  String get currentStage => 'المرحلة الحالية';

  @override
  String get nextApprover => 'المعتمد التالي';

  @override
  String get timeline => 'الجدول الزمني';

  @override
  String get noTimelineEvents => 'لا توجد أحداث في الجدول الزمني بعد.';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get cancelRequestTitle => 'إلغاء هذا الطلب؟';

  @override
  String cancelRequestMessage(String requestNumber) {
    return 'إلغاء الطلب $requestNumber؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get requestCancelled => 'تم إلغاء الطلب.';

  @override
  String requestSubmitted(String requestNumber) {
    return 'تم تقديم الطلب $requestNumber.';
  }

  @override
  String get newAccessRequestSubtitle =>
      'اختر النظام والصلاحية، ثم اشرح سبب حاجتك للوصول.';

  @override
  String justificationHelper(int min) {
    return 'على الأقل $min حرفاً.';
  }

  @override
  String get selectDate => 'اختر تاريخاً';

  @override
  String get durationTemporary => 'مؤقت';

  @override
  String get durationPermanent => 'دائم';

  @override
  String get urgencyNormal => 'عادي';

  @override
  String get urgencyUrgent => 'عاجل';

  @override
  String get urgencyCritical => 'حرج';

  @override
  String get stageRequester => 'مقدّم الطلب';

  @override
  String get stageManager => 'المدير';

  @override
  String get stageSecurity => 'الأمن';

  @override
  String get stageProvisioning => 'التنفيذ';

  @override
  String get stageComplete => 'مكتمل';

  @override
  String get riskLow => 'منخفض';

  @override
  String get riskMedium => 'متوسط';

  @override
  String get riskHigh => 'عالٍ';

  @override
  String get riskCritical => 'حرج';

  @override
  String get review => 'مراجعة';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get approvalDetail => 'قرار الموافقة';

  @override
  String get approvalStageManager => 'موافقة المدير';

  @override
  String get approvalStageSecurity => 'موافقة الأمن';

  @override
  String approvalStageLabel(String stage) {
    return 'المرحلة: $stage';
  }

  @override
  String get noApprovalsMessage => 'أنت على اطلاع كامل.';

  @override
  String get noCompletedApprovals => 'لا توجد موافقات مكتملة';

  @override
  String get noCompletedApprovalsMessage =>
      'ستظهر المهام التي تم البت فيها هنا.';

  @override
  String get approveConfirmTitle => 'الموافقة على هذا الطلب؟';

  @override
  String approveConfirmMessage(String requestNumber) {
    return 'هل أنت متأكد من الموافقة على طلب الصلاحية $requestNumber؟';
  }

  @override
  String get rejectConfirmTitle => 'رفض هذا الطلب؟';

  @override
  String get rejectConfirmMessage => 'يرجى تقديم سبب الرفض.';

  @override
  String get optionalComment => 'تعليق (اختياري)';

  @override
  String get optionalCommentHint =>
      'أضف ملاحظة لمقدّم الطلب أو المعتمد التالي.';

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get rejectionReasonHint => 'اشرح سبب رفض هذا الطلب.';

  @override
  String get rejectionCommentRequired => 'سبب الرفض مطلوب.';

  @override
  String get decisionComment => 'تعليق القرار';

  @override
  String get confirmApprove => 'تأكيد الموافقة';

  @override
  String get confirmReject => 'تأكيد الرفض';

  @override
  String approvalApprovedSuccess(String requestNumber) {
    return 'تمت الموافقة على الطلب $requestNumber.';
  }

  @override
  String approvalRejectedSuccess(String requestNumber) {
    return 'تم رفض الطلب $requestNumber.';
  }

  @override
  String get errorApprovalNotFound => 'تعذّر العثور على مهمة الموافقة هذه.';

  @override
  String get errorApprovalNotPending => 'تم البت في هذه الموافقة مسبقاً.';

  @override
  String get errorNotTaskAssignee =>
      'يمكن للمعتمد المعيّن فقط البت في هذه المهمة.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية لهذا الإجراء.';

  @override
  String get close => 'إغلاق';

  @override
  String get viewMetadata => 'عرض البيانات الوصفية';

  @override
  String get searchActorEmail => 'البحث ببريد الفاعل';

  @override
  String get filterAction => 'الإجراء';

  @override
  String get filterEntityType => 'الكيان';

  @override
  String get filterFromDate => 'من تاريخ';

  @override
  String get filterToDate => 'إلى تاريخ';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String get noAuditLogs => 'لا توجد سجلات تدقيق تطابق عوامل التصفية';

  @override
  String get noAuditLogsMessage => 'ستظهر هنا أحداث الأمن والإدارة.';

  @override
  String get noAuditLogsFilteredMessage => 'حاول تغيير عوامل التصفية.';

  @override
  String get auditActorUnknown => 'فاعل غير معروف';

  @override
  String auditEntityLabel(String entityType) {
    return 'الكيان: $entityType';
  }

  @override
  String get auditMetadataTitle => 'تفاصيل حدث التدقيق';

  @override
  String get auditNoMetadata => 'لا توجد بيانات وصفية مسجّلة.';

  @override
  String get auditFieldAction => 'الإجراء';

  @override
  String get auditFieldActor => 'الفاعل';

  @override
  String get auditFieldEntity => 'نوع الكيان';

  @override
  String get auditFieldEntityId => 'معرّف الكيان';

  @override
  String get auditFieldWhen => 'الوقت';

  @override
  String get auditFieldIp => 'عنوان IP';

  @override
  String get auditFieldUserAgent => 'وكيل المستخدم';

  @override
  String get auditFieldMetadata => 'البيانات الوصفية';

  @override
  String get previousPage => 'الصفحة السابقة';

  @override
  String get nextPage => 'الصفحة التالية';

  @override
  String auditPageStatus(int page, int totalPages, int total) {
    return 'صفحة $page من $totalPages · $total حدث';
  }

  @override
  String get errorNotFound => 'تعذّر العثور على العنصر المطلوب.';

  @override
  String get errorInvalidAudienceFilter => 'اختيار جمهور الإشعار غير صالح.';

  @override
  String get errorFusionConfigurationMissing =>
      'Oracle Fusion غير مُعدّ في هذه البيئة.';

  @override
  String get errorFusionProvisioningFailed =>
      'فشل التزويد عبر Oracle Fusion. حاول مرة أخرى لاحقاً.';

  @override
  String get auditActionAuthLogin => 'تسجيل الدخول';

  @override
  String get auditActionAuthLogout => 'تسجيل الخروج';

  @override
  String get auditActionNotificationCreated => 'تم إنشاء إشعار';

  @override
  String get auditActionNotificationPublished => 'تم نشر إشعار';

  @override
  String get auditActionNotificationRead => 'تمت قراءة إشعار';

  @override
  String get auditActionNotificationCancelled => 'تم إلغاء إشعار';

  @override
  String get auditActionAccessRequestSubmitted => 'تم إرسال طلب صلاحية';

  @override
  String get auditActionAccessRequestCancelled => 'تم إلغاء طلب صلاحية';

  @override
  String get auditActionAccessRequestProvisioningStarted => 'بدأ التزويد';

  @override
  String get auditActionAccessRequestCompleted => 'اكتمل طلب الصلاحية';

  @override
  String get auditActionAccessRequestFailed => 'فشل طلب الصلاحية';

  @override
  String get auditActionApprovalManagerApproved => 'موافقة المدير';

  @override
  String get auditActionApprovalManagerRejected => 'رفض المدير';

  @override
  String get auditActionApprovalSecurityApproved => 'موافقة الأمن';

  @override
  String get auditActionApprovalSecurityRejected => 'رفض الأمن';

  @override
  String get auditEntityUser => 'مستخدم';

  @override
  String get auditEntityNotification => 'إشعار';

  @override
  String get auditEntityAccessRequest => 'طلب صلاحية';

  @override
  String get auditEntityApprovalTask => 'مهمة موافقة';
}
