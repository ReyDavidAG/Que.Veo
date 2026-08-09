import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieMapProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final getMovie = ref.watch(movieRepositoryProvider).getMovieById;
  return MovieMapNotifier(getMovie: getMovie);
});

/*
{
  "movieId1": Movie(),
  "movieId2": Movie(),
  ...
}
*/

typedef GetMovieCallBack = Future<Movie> Function(String movieId);

class MovieMapNotifier extends StateNotifier<Map<String, Movie>> {
  final GetMovieCallBack getMovie;
  MovieMapNotifier({required this.getMovie}) : super({});

  Future<void> loadMovie(String movieId) async {
    if (state[movieId] != null) return;

    final Movie movie = await getMovie(movieId);
    state = {
      ...state,
      movieId: movie,
    };
  }
}
