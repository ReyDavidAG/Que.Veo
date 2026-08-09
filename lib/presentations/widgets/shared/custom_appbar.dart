import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/presentations/delegates/search_movies_delegate.dart';
import 'package:cinemapedia/presentations/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    // Shadow only needed in light mode (dark already has contrast against poster).
    final textShadow = brightness == Brightness.light
        ? const [
            Shadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 1)),
          ]
        : null;

    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: colors.text,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          shadows: textShadow,
        );

    // 'colors' will be used by the action buttons below.

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.accent, colors.accent.withAlpha(180)],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.movie_filter_rounded,
                size: 22,
                color: colors.accentInk,
                shadows: const [
                  Shadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.text, colors.accent],
              ).createShader(bounds),
              child: Text(
                'QuéVeo',
                style: titleStyle?.copyWith(color: Colors.white),
              ),
            ),
            const Spacer(),
            _HeaderActionButton(
              icon: Icons.search_rounded,
              tooltip: 'Buscar',
              onPressed: () async {
                final searchQuery = ref.read(searchQueryProvider);
                final searchedMovies = ref.read(searchMoviesProvider);

                final movie = await showSearch(
                  query: searchQuery,
                  context: context,
                  delegate: SearchMoviesDelegate(
                    previousResults: searchedMovies,
                    searchMovies: (query) =>
                        ref.read(searchMoviesProvider.notifier).searchMoviesByQuery(query),
                  ),
                );
                if (movie != null && context.mounted) {
                  context.push('/home/0/movie/${movie.id}');
                }
              },
            ),
            _HeaderActionButton(
              icon: Icons.tune_rounded,
              tooltip: 'Ajustes',
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Material(
      color: brightness == Brightness.light
          ? Colors.white.withAlpha(180)
          : Colors.white.withAlpha(20),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon),
        color: brightness == Brightness.light ? const Color(0xFF0E1427) : Colors.white,
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
