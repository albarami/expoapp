import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/widgets.dart';

/// Temporary placeholder until feature tasks land.
class FoundationPlaceholderScreen extends StatelessWidget {
  const FoundationPlaceholderScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpoAppScaffold(
      title: title,
      body: EmptyState(
        icon: Icons.construction_outlined,
        title: l10n.comingSoon,
        message: l10n.foundationPlaceholder,
      ),
    );
  }
}
