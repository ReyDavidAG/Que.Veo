import 'package:cinemapedia/domain/entities/watch_providers.dart';
import 'package:cinemapedia/presentations/providers/movies/watch_providers_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final watchProvidersProvider =
    StateNotifierProvider<WatchProvidersNotifier, Map<String, WatchProviders>>((ref) {
  final getWatchProvidersByMovieId = ref.watch(watchProvidersRepositoryProvider).getWatchProviders;
  return WatchProvidersNotifier((movieId) => getWatchProvidersByMovieId(movieId));
});

typedef WatchProvidersCallback = Future<WatchProviders> Function(String movieId);

class WatchProvidersNotifier extends StateNotifier<Map<String, WatchProviders>> {
  final WatchProvidersCallback getWatchProvidersByMovieId;
  WatchProvidersNotifier(this.getWatchProvidersByMovieId) : super({});

  Future<void> loadWatchProviders(String movieId) async {
    if (state[movieId] != null) return;
    final watchProviders = await getWatchProvidersByMovieId(movieId);

    state = {...state, movieId: watchProviders};
  }
}
