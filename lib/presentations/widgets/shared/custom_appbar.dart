import 'package:cinemapedia/config/theme/app_colors.dart';
import 'package:cinemapedia/config/theme/app_spacing.dart';
import 'package:cinemapedia/presentations/delegates/search_movies_delegate.dart';
import 'package:cinemapedia/presentations/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reference migration to the token system. Reads colours from `AppColors` and
/// spacing from `AppSpacing`. The rest of the codebase still has hardcoded
/// values — that is intentional, future phases will follow this pattern.
class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.text);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Icon(Icons.movie_filter_sharp, size: 28, color: AppColors.icon),
            const SizedBox(width: AppSpacing.sm),
            Text('QuéVeo', style: textStyle),
            const Spacer(),
            IconButton(
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
              icon: const Icon(Icons.search),
              color: AppColors.icon,
              tooltip: 'Buscar',
            ),
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
              color: AppColors.icon,
              tooltip: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
