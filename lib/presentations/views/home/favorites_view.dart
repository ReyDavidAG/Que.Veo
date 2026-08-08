import 'package:cinemapedia/presentations/providers/favorites_localstorage/favorites_provider.dart';
import 'package:cinemapedia/presentations/widgets/movies/movies_masonry.dart';
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
    ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);
    final myMovieList = favoriteMovies.values.toList();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Color(0xFF0E1427), Color(0xFF121A34)],
                stops: [0.0, 0.35, 0.95],
              ),
            ),
            child: MovieMasonry(
              movies: myMovieList,
              loadNextPage: () => ref.read(favoriteMoviesProvider.notifier).loadNextPage(),
            ),
          ),
        ],
      ),
    );
  }
}
