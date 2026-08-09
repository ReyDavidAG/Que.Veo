import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/presentations/providers/favorites_localstorage/local_storage_repository_provider.dart';
import 'package:cinemapedia/repositories/localstorage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteMoviesProvider = StateNotifierProvider<StorageMoviesNotifier, Map<int, Movie>>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);

  return StorageMoviesNotifier(localStorageRepository: localStorageRepository);
});

class StorageMoviesNotifier extends StateNotifier<Map<int, Movie>> {
  int page = 0;
  final LocalStorageRepository localStorageRepository;

  StorageMoviesNotifier({required this.localStorageRepository}) : super({});

  Future<List<Movie>> loadNextPage() async {
    final response = await localStorageRepository.loadFavoriteMovies(
      limit: 10,
      offset: page * 10,
    );

    final movies = response.map((movie) => MovieMapper.favoriteDBToEntity(movie)).toList();

    page++;

    final tempMovies = <int, Movie>{};

    for (final movie in movies) {
      // state = {...state, movie.id: movie};
      tempMovies[movie.id] = movie;
    }

    state = {...state, ...tempMovies};

    return movies;
  }

  Future<void> toggleFavoriteMovie(Movie movie) async {
    final isFavorite = await localStorageRepository.isMovieFavorite(movie.id);
    await localStorageRepository.toggleFavorite(movie);

    if (isFavorite) {
      state.remove(movie.id);
      state = {...state};
      return;
    }

    state = {...state, movie.id: movie};
  }
}
