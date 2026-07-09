# Localization and RTL

## Required languages

- English (`en`)
- Arabic (`ar`)

## Flutter implementation

Use Flutter localization with ARB files:

```text
lib/l10n/app_en.arb
lib/l10n/app_ar.arb
```

Configure `flutter gen-l10n`.

## Required app strings

At minimum include keys for:

```json
{
  "appName": "ExpoApp",
  "login": "Login",
  "email": "Email",
  "password": "Password",
  "dashboard": "Dashboard",
  "notifications": "Notifications",
  "requests": "Requests",
  "approvals": "Approvals",
  "auditLogs": "Audit Logs",
  "profile": "Profile",
  "settings": "Settings",
  "logout": "Logout",
  "newAccessRequest": "New Access Request",
  "createNotification": "Create Notification",
  "markAsRead": "Mark as read",
  "approve": "Approve",
  "reject": "Reject",
  "cancel": "Cancel",
  "submit": "Submit",
  "retry": "Retry",
  "noNotifications": "No notifications yet",
  "noRequests": "No requests yet",
  "noApprovals": "No approvals pending",
  "businessJustification": "Business justification",
  "system": "System",
  "securityRole": "Security role",
  "duration": "Duration",
  "urgency": "Urgency",
  "startDate": "Start date",
  "endDate": "End date"
}
```

Arabic examples:

```json
{
  "appName": "ExpoApp",
  "login": "تسجيل الدخول",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "dashboard": "الرئيسية",
  "notifications": "الإشعارات",
  "requests": "الطلبات",
  "approvals": "الموافقات",
  "auditLogs": "سجلات التدقيق",
  "profile": "الملف الشخصي",
  "settings": "الإعدادات",
  "logout": "تسجيل الخروج",
  "newAccessRequest": "طلب صلاحية جديد",
  "createNotification": "إنشاء إشعار",
  "markAsRead": "تحديد كمقروء",
  "approve": "موافقة",
  "reject": "رفض",
  "cancel": "إلغاء",
  "submit": "إرسال",
  "retry": "إعادة المحاولة",
  "noNotifications": "لا توجد إشعارات حتى الآن",
  "noRequests": "لا توجد طلبات حتى الآن",
  "noApprovals": "لا توجد موافقات معلقة",
  "businessJustification": "مبرر العمل",
  "system": "النظام",
  "securityRole": "الصلاحية الأمنية",
  "duration": "المدة",
  "urgency": "الأولوية",
  "startDate": "تاريخ البداية",
  "endDate": "تاريخ النهاية"
}
```

## RTL rules

- Arabic locale must set `Directionality.rtl`.
- Icons that imply direction must flip where necessary.
- Avoid manually setting left/right; use start/end.
- Padding should use `EdgeInsetsDirectional`.
- Align text using `TextAlign.start`.
- Test main screens in Arabic.

## Backend localization

Backend stores both English and Arabic text for notifications, departments, systems, and roles.

API returns both:

```json
{
  "nameEn": "Operations",
  "nameAr": "العمليات"
}
```

Flutter chooses display text based on locale. If Arabic text is missing, fallback to English.

## Date formatting

Use `intl`.

Do not manually format dates.

## Language switching

Settings/profile should include language switch.

Behavior:

1. User selects language.
2. App stores preference locally.
3. App rebuilds with selected locale.
4. Layout direction changes.
5. API calls unaffected.

## Validation messages

All validation messages shown in Flutter must be localizable.

Backend errors may return English codes/messages. Flutter should map known error codes to localized messages when possible.

Example mapping:

| Error code | English | Arabic |
|---|---|---|
| `MANAGER_NOT_FOUND` | No manager found for this request. | لم يتم العثور على مدير لهذا الطلب. |
| `ROLE_NOT_REQUESTABLE` | This role cannot be requested. | لا يمكن طلب هذه الصلاحية. |
| `DUPLICATE_ACTIVE_REQUEST` | You already have an active request for this role. | لديك طلب نشط بالفعل لهذه الصلاحية. |
