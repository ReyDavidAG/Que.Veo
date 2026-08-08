import 'package:cinemapedia/infrastructure/datasources/watch_providers_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/reporsitories/watch_providers_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final watchProvidersRepositoryProvider = Provider<WatchProvidersRepositoryImpl>((ref) {
  return WatchProvidersRepositoryImpl(WatchProvidersMoviedbDatasource());
});
