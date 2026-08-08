import 'package:cinemapedia/domain/datasources/watch_providers_datasource.dart';
import 'package:cinemapedia/domain/entities/watch_providers.dart';
import 'package:cinemapedia/repositories/watch_providers_repository.dart';

class WatchProvidersRepositoryImpl implements WatchProvidersRepository {
  final WatchProvidersDatasource datasource;
  WatchProvidersRepositoryImpl(this.datasource);
  @override
  Future<WatchProviders> getWatchProviders(String movieId) {
    return datasource.getWatchProviders(movieId);
  }
}
