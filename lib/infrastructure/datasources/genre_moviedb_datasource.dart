import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/genre_datasource.dart';
import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:dio/dio.dart';

class GenreMovieDBDataSource implements GenreDataSource {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3', queryParameters: {
    'api_key': Environment.movieDbKey,
    'language': 'es-MX',
  }, headers: {
    'Authorization': 'Bearer ${Environment.movieDbAccessToken}',
  }));
  @override
  Future<GenreResponse> getGenres() async {
    final response = await dio.get('/genre/movie/list');
    final genreResponse = GenreResponse.fromJson(response.data);
    return genreResponse;
  }
}
