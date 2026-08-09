import 'dart:ui';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/0');
        break;
      case 1:
        context.go('/home/1');
        break;
      case 2:
        context.go('/home/2');
        break;
      default:
        context.go('/home/0');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          colors.surfaceRaised.withAlpha(220),
                          colors.surface.withAlpha(220),
                        ]
                      : [
                          Colors.white.withAlpha(230),
                          Colors.white.withAlpha(210),
                        ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.rule, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(80)
                        : Colors.black.withAlpha(40),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Theme(
                data: theme.copyWith(
                  splashColor: colors.accent.withAlpha(40),
                  highlightColor: colors.accent.withAlpha(30),
                ),
                child: SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      _NavTab(
                        index: 0,
                        currentIndex: currentIndex,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Inicio',
                        onTap: () => onTap(0, context),
                      ),
                      _NavTab(
                        index: 1,
                        currentIndex: currentIndex,
                        icon: Icons.category_outlined,
                        activeIcon: Icons.category_rounded,
                        label: 'Categorías',
                        onTap: () => onTap(1, context),
                      ),
                      _NavTab(
                        index: 2,
                        currentIndex: currentIndex,
                        icon: Icons.favorite_border,
                        activeIcon: Icons.favorite_rounded,
                        label: 'Favoritos',
                        onTap: () => onTap(2, context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavTab({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = index == currentIndex;
    final iconColor = isActive ? colors.accent : colors.iconMuted;
    final labelColor = isActive ? colors.accent : colors.iconMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: colors.accent.withAlpha(40),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: isActive ? 36 : 0,
                  height: isActive ? 28 : 0,
                  decoration: BoxDecoration(
                    color: colors.accent.withAlpha(isActive ? 40 : 0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey<bool>(isActive),
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: labelColor,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
