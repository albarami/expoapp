import 'package:flutter/material.dart';

import '../../../../app/theme_tokens.dart';

/// Compact metric tile used on the role-aware dashboard.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = emphasis
        ? scheme.primaryContainer
        : scheme.surfaceContainerLowest;
    final foreground = emphasis ? scheme.onPrimaryContainer : scheme.onSurface;
    final iconColor = emphasis ? scheme.onPrimaryContainer : scheme.primary;

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: emphasis
                  ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Semantics(
          button: onTap != null,
          label: '$label: $value',
          child: SizedBox(
            height: 120,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Placeholder skeleton matching [MetricCard] dimensions.
class MetricCardSkeleton extends StatelessWidget {
  const MetricCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
