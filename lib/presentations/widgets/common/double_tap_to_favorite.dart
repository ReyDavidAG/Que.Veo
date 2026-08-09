import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wrap any child in this to give it the Instagram double-tap-to-favourite
/// gesture. Double-tap fires [onToggle], shows a heart that scales up and
/// floats upward while fading out, and triggers a medium haptic.
class DoubleTapToFavorite extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final Widget child;

  const DoubleTapToFavorite({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    required this.child,
  });

  @override
  State<DoubleTapToFavorite> createState() => _DoubleTapToFavoriteState();
}

class _DoubleTapToFavoriteState extends State<DoubleTapToFavorite> with TickerProviderStateMixin {
  late final AnimationController _controller;
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeEntry();
    super.dispose();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  void _handleDoubleTap() {
    HapticFeedback.mediumImpact();
    widget.onToggle();
    _showOverlay();
  }

  void _showOverlay() {
    _removeEntry(); // drop any leftover entry from a previous double-tap
    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final center = topLeft + Offset(size.width / 2, size.height / 2);

    _entry = OverlayEntry(
      builder: (_) {
        return _FloatingHeart(center: center, onComplete: _removeEntry);
      },
    );
    overlay.insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  final Offset center;
  final VoidCallback onComplete;

  const _FloatingHeart({required this.center, required this.onComplete});

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward().whenComplete(widget.onComplete);
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
        final t = _controller.value;
        final opacity = t < 0.4 ? 1.0 : 1.0 - ((t - 0.4) / 0.6);
        // Scale: pop in over the first 15%, then settle
        final scale = t < 0.15 ? (t / 0.15) * 1.3 : 1.3 - ((t - 0.15) / 0.85) * 0.3;
        // Translate upward over the full duration
        final dy = -120 * t;
        return Positioned(
          left: widget.center.dx - 60,
          top: widget.center.dy - 60 + dy,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: const Icon(Icons.favorite, size: 120, color: AppColors.accent),
              ),
            ),
          ),
        );
      },
    );
  }
}
