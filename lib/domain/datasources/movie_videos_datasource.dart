import 'package:cinemapedia/domain/entities/movie_videos.dart';

abstract class MovieVideosDatasource {
  Future<MovieVideos> getMovieVideos({required String movieId});
}
