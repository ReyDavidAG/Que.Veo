import 'package:cinemapedia/domain/entities/movie_videos.dart';

abstract class MovieVideosRepository {
  Future<MovieVideos> getMovieVideos({required String movieId});
}
