import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/datasources/watch_providers_datasource.dart';
import 'package:cinemapedia/domain/entities/watch_providers.dart';
import 'package:dio/dio.dart';

class WatchProvidersMoviedbDatasource implements WatchProvidersDatasource {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3', queryParameters: {
    'api_key': Environment.movieDbKey,
    'language': 'es-MX',
  }, headers: {
    'Authorization': 'Bearer ${Environment.movieDbAccessToken}',
  }));
  @override
  Future<WatchProviders> getWatchProviders(String movieId) async {
    try {
      final response = await dio.get('/movie/$movieId/watch/providers');
      final watchProviders = WatchProviders.fromJson(response.data);
      return watchProviders;
    } catch (e) {
      throw Exception('Failed to load watch providers');
    }
  }
}
