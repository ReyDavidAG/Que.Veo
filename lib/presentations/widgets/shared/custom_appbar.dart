import 'package:cinemapedia/presentations/delegates/search_movies_delegate.dart';
import 'package:cinemapedia/presentations/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onPrimary,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.movie_filter_sharp,
              size: 28,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              'QuéVeo',
              style: textStyle,
            ),
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
                        searchMovies: (query) {
                          return ref.read(searchMoviesProvider.notifier).searchMoviesByQuery(query);
                        }));
                if (movie != null && context.mounted) {
                  context.push('/home/0/movie/${movie.id}');
                }
              },
              icon: const Icon(Icons.search),
              color: theme.colorScheme.onPrimary,
              tooltip: 'Buscar',
            ),
          ],
        ),
      ),
    );
  }
}
