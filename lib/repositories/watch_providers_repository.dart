import 'package:cinemapedia/domain/entities/watch_providers.dart';

abstract class WatchProvidersRepository {
  Future<WatchProviders> getWatchProviders(String movieId);
}
