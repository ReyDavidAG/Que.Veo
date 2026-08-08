import 'package:cinemapedia/domain/entities/movie_videos.dart';
import 'package:cinemapedia/presentations/providers/movie_videos/movie_videos_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieVideosProvider = StateNotifierProvider<MovieVideosNotifier, Map<String, MovieVideos>>(
  (ref) {
    final getMovieVideos = ref.watch(movieVideosRepositoryProvider).getMovieVideos;

    return MovieVideosNotifier(getMovieVideos);
  },
);

typedef MovieVideosCallback = Future<MovieVideos> Function({required String movieId});

class MovieVideosNotifier extends StateNotifier<Map<String, MovieVideos>> {
  final MovieVideosCallback getMovieVideos;
  MovieVideosNotifier(this.getMovieVideos) : super({});

  Future<void> loadMovieVideos(String movieId) async {
    if (state[movieId] != null) return;
    final movieVideos = await getMovieVideos(movieId: movieId);

    state = {...state, movieId: movieVideos};
  }
}
