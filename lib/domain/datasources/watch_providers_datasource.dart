import 'package:cinemapedia/domain/entities/watch_providers.dart';

abstract class WatchProvidersDatasource {
  Future<WatchProviders> getWatchProviders(String movieId);
}
