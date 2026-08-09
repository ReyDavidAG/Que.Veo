import 'package:cinemapedia/config/theme/theme_context.dart';
import 'package:cinemapedia/presentations/providers/favorites_localstorage/favorites_provider.dart';
import 'package:cinemapedia/presentations/providers/favorites_localstorage/is_favorite_movie_provider.dart';
import 'package:cinemapedia/presentations/widgets/movies/movies_masonry.dart';
import 'package:cinemapedia/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> {
  @override
  void initState() {
    super.initState();
    ref.read(favoriteMoviesProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);
    final myMovieList = favoriteMovies.values.toList();
    final heroGradient = context.colors.heroGradient;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: heroGradient,
              stops: const [0.0, 0.35, 0.95],
            ),
          ),
          child: myMovieList.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'Aún no tienes favoritos',
                  body: 'Toca el corazón en cualquier película para guardarla aquí. Mantén presionado para quitar.',
                )
              : MovieMasonry(
                  movies: myMovieList,
                  loadNextPage: () => ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
                  onMovieLongPress: (movie) async {
                    await ref.read(favoriteMoviesProvider.notifier).toggleFavoriteMovie(movie);
                    ref.invalidate(isFavoriteMovieProvider(movie.id));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Quitado de favoritos'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
