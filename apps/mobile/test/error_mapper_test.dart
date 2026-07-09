import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/errors/error_mapper.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';

void main() {
  test('localizeApiError maps known codes', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'MANAGER_NOT_FOUND', message: 'x'),
      ),
      l10n.errorManagerNotFound,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'NETWORK_ERROR', message: 'x'),
      ),
      l10n.networkError,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'INVALID_ACCESS_DATES', message: 'x'),
      ),
      l10n.errorInvalidAccessDates,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'REQUEST_NOT_CANCELABLE', message: 'x'),
      ),
      l10n.errorRequestNotCancelable,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'APPROVAL_TASK_NOT_PENDING', message: 'x'),
      ),
      l10n.errorApprovalNotPending,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'NOT_TASK_ASSIGNEE', message: 'x'),
      ),
      l10n.errorNotTaskAssignee,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'NOT_FOUND', message: 'x'),
      ),
      l10n.errorNotFound,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'INVALID_AUDIENCE_FILTER', message: 'x'),
      ),
      l10n.errorInvalidAudienceFilter,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'FUSION_CONFIGURATION_MISSING', message: 'x'),
      ),
      l10n.errorFusionConfigurationMissing,
    );
    expect(
      localizeApiError(
        l10n,
        const ApiError(code: 'FUSION_PROVISIONING_FAILED', message: 'x'),
      ),
      l10n.errorFusionProvisioningFailed,
    );
  });
}
