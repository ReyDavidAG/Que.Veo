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
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surfaceRaised.withAlpha(170)
                    : colors.surface.withAlpha(220),
                border: Border.all(color: colors.rule),
              ),
              child: Theme(
                data: theme.copyWith(
                  splashColor: colors.iconMuted.withAlpha(40),
                  highlightColor: colors.iconMuted.withAlpha(30),
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: colors.text,
                  unselectedItemColor: colors.iconMuted,
                  onTap: (index) => onTap(index, context),
                  currentIndex: currentIndex,
                  selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                    letterSpacing: .2,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: colors.iconMuted,
                  ),
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category_outlined),
                      activeIcon: Icon(Icons.category),
                      label: 'Categorías',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_border),
                      activeIcon: Icon(Icons.favorite),
                      label: 'Favoritos',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
