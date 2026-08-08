import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Shared empty state — one sentence, optional body, optional CTA. No illustration.
///
/// Use whenever a list view has zero results to render: an empty search, a
/// favourites list with no movies saved, a genre that returned nothing.
///
/// Keeps the app on-brand for the four cases that used to return
/// `SizedBox.shrink()` silently.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FadeIn(
          duration: const Duration(milliseconds: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.iconMuted),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: AppColors.text),
              ),
              if (body != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.accentInk,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
