import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/actor_details_datasource.dart';
import 'package:cinemapedia/domain/entities/actor_details.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/actor_credits_response.dart';
import 'package:dio/dio.dart';

class ActorDetailsMoviedbDatasouce extends ActorDetailsDataSource {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3', queryParameters: {
    'api_key': Environment.movieDbKey,
    'language': 'es-MX',
  }, headers: {
    'Authorization': 'Bearer ${Environment.movieDbAccessToken}',
  }));

  @override
  Future<ActorDetails> getActorDetails(String actorId) async {
    final response = await dio.get('/person/$actorId');

    final details = ActorDetails.fromJson(response.data);

    return details;
  }

  @override
  Future<List<Movie>> getActorMovies(String actorId) async {
    final response = await dio.get('/person/$actorId/movie_credits');

    final castMovies = CastMovie.fromJson(response.data);

    final movies = castMovies.cast.map((movieCast) => MovieMapper.castToEntity(movieCast)).toList();

    return movies;
  }
}
