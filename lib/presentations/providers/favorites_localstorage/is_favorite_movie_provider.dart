import 'package:cinemapedia/presentations/providers/favorites_localstorage/favorites_provider.dart';
import 'package:cinemapedia/presentations/providers/favorites_localstorage/local_storage_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final isFavoriteMovieProvider = FutureProvider.family.autoDispose<bool, int>((
final isFavoriteMovieProvider = FutureProvider.family<bool, int>((
  ref,
  movieId,
) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return localStorageRepository.isMovieFavorite(movieId);
});

final isFavoriteInMemoryProvider = Provider.family<bool, int>((ref, movieId) {
  final favs = ref.watch(favoriteMoviesProvider);
  return favs.containsKey(movieId);
});
