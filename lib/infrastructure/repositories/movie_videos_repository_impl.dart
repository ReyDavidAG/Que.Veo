import 'package:cinemapedia/domain/datasources/movie_videos_datasource.dart';
import 'package:cinemapedia/domain/entities/movie_videos.dart';
import 'package:cinemapedia/repositories/movie_videos_repository.dart';

class MovieVideosRepositoryImpl implements MovieVideosRepository {
  final MovieVideosDatasource datasource;
  MovieVideosRepositoryImpl({required this.datasource});
  @override
  Future<MovieVideos> getMovieVideos({required String movieId}) {
    return datasource.getMovieVideos(movieId: movieId);
  }
}
