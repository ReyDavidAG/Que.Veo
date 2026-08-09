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
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.text);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.movie_filter_sharp, size: 28, color: colors.icon),
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
              color: colors.icon,
              tooltip: 'Buscar',
            ),
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
              color: colors.icon,
              tooltip: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }
}
