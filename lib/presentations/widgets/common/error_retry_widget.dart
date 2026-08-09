import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// Shared error state — same shape as [EmptyStateWidget], with the action
/// defaulted to "Reintentar". Use whenever a fetch throws.
///
/// The error message is shown only if it is short. Long driver messages are
/// hidden because they leak implementation detail to the user; the retry
/// button is the only thing that matters.
class ErrorRetryWidget extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;
  final String title;

  const ErrorRetryWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.title = 'No pudimos cargar esto',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final message = _safeMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: FadeIn(
          duration: const Duration(milliseconds: 220),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: colors.icon),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: colors.text),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: colors.accentInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _safeMessage(Object? error) {
    if (error == null) return null;
    final s = error.toString();
    if (s.length > 140) return null;
    return s;
  }
}
