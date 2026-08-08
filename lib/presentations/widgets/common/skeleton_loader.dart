import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Placeholder shown while data loads. A simple pulsing rectangle — no `shimmer`
/// package, no extra dependency. Use when a `CircularProgressIndicator` would
/// be too loud for the surface.
///
/// Pass `width` and `height` to size the box; without them it fills its parent.
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.radius = AppSpacing.radiusCard,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(AppColors.surface, AppColors.surfaceRaised, t),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

/// Convenience: a full-screen skeleton list that fades in while the first
/// real fetch is in flight. Sized to roughly match a single movie row.
class SkeletonMovieRow extends StatelessWidget {
  const SkeletonMovieRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs),
      child: Row(
        children: [
          SkeletonLoader(width: 80, height: 120, radius: AppSpacing.radiusCard),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(height: 14),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(height: 12, width: 160),
                SizedBox(height: AppSpacing.xs2),
                SkeletonLoader(height: 12, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
