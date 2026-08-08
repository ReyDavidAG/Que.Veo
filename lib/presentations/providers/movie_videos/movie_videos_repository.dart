import 'package:cinemapedia/infrastructure/datasources/movie_videos_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_videos_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieVideosRepositoryProvider = Provider<MovieVideosRepositoryImpl>((ref) {
  return MovieVideosRepositoryImpl(
    datasource: MovieVideosMoviedbDatasource(),
  );
});
