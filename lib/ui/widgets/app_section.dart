import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const AppSection({
    super.key,
    required this.title,
    this.description,
    required this.child,
    this.padding,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        child,
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.xl),
          Divider(
            height: 1,
            thickness: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }
}