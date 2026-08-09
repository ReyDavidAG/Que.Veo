import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/movie_videos_datasource.dart';
import 'package:cinemapedia/domain/entities/movie_videos.dart';
import 'package:dio/dio.dart';

class MovieVideosMoviedbDatasource implements MovieVideosDatasource {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3', queryParameters: {
    'api_key': Environment.movieDbKey,
  }, headers: {
    'Authorization': 'Bearer ${Environment.movieDbAccessToken}',
  }));
  @override
  Future<MovieVideos> getMovieVideos({required String movieId}) {
    return dio
        .get('/movie/$movieId/videos')
        .then((response) => MovieVideos.fromJson(response.data));
  }
}
