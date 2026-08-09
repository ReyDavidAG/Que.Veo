import 'package:cinemapedia/config/theme/app_motion.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Instagram-style favourite toggle. Tap to flip; on flip it pulses (scale
/// 0.7 → 1.2 → 1.0 over 180 ms) and fires a light haptic. The icon swaps
/// between outlined and filled with a 120 ms crossfade.
class AnimatedHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const AnimatedHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 28,
  });

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          // Bounce curve: 0 → overshoot at 0.6 → settle at 1
          final t = _controller.value;
          final scale = t == 0
              ? 1.0
              : (t < 0.6 ? 0.7 + (t / 0.6) * 0.5 : 1.2 - ((t - 0.6) / 0.4) * 0.2);
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedSwitcher(
          duration: AppMotion.micro,
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
          child: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(widget.isFavorite),
            size: widget.size,
            color: widget.isFavorite ? context.colors.accent : context.colors.icon,
            shadows: widget.isFavorite
                ? [const Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))]
                : null,
          ),
        ),
      ),
    );
  }
}
