import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getNowPlayingMovies;

  return MoviesNotifier(movieCallback: fetchMoreMovies);
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getPopularMovies;

  return MoviesNotifier(movieCallback: fetchMoreMovies);
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getUpcomingMovies;

  return MoviesNotifier(movieCallback: fetchMoreMovies);
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getTopRatedMovies;

  return MoviesNotifier(movieCallback: fetchMoreMovies);
});

final similarMoviesProvider =
    StateNotifierProvider.family<MoviesNotifier, List<Movie>, String>((ref, movieId) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getSimilarMovies;

  return MoviesNotifier(movieCallback: ({int page = 1}) => fetchMoreMovies(movieId, page: page));
});

final moviesByGenreProvider =
    StateNotifierProvider.family<MoviesNotifier, List<Movie>, String>((ref, genreId) {
  final fetchMoreMovies = ref.watch(movieRepositoryProvider).getMoviesByGenre;

  return MoviesNotifier(
      movieCallback: ({int page = 1}) => fetchMoreMovies(genreId: genreId, page: page));
});

typedef MovieCallback = Future<List<Movie>> Function({int page});

class MoviesNotifier extends StateNotifier<List<Movie>> {
  int currentPage = 0;
  bool isLoading = false;
  MovieCallback movieCallback;

  MoviesNotifier({required this.movieCallback}) : super([]);

  Future<void> loadNextPage() async {
    if (isLoading) return;
    currentPage++;

    isLoading = true;
    final List<Movie> movies = await movieCallback(page: currentPage);

    state = [...state, ...movies];

    await Future.delayed(const Duration(milliseconds: 300));
    isLoading = false;
  }
}
