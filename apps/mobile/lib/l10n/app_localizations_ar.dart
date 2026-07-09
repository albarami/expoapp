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
  String get noRequests => 'لا توجد طلبات حتى الآن';

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
  String get networkError => 'خطأ في الشبكة. تحقق من الاتصال وحاول مرة أخرى.';

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
}
