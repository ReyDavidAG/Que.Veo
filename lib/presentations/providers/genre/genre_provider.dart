import 'package:cinemapedia/domain/entities/genre.dart';
import 'package:cinemapedia/presentations/providers/genre/genre_provider_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final genreProvider = StateNotifierProvider<GenreNotifier, List<Genre>>((ref) {
  final getGenres = ref.watch(genreProviderRepository).getGenres;
  return GenreNotifier(getGenres);
});

typedef GetGenresCallback = Future<GenreResponse> Function();

class GenreNotifier extends StateNotifier<List<Genre>> {
  final GetGenresCallback getGenresCallback;

  GenreNotifier(this.getGenresCallback) : super([]);

  Future<void> loadGenres() async {
    if (state.isNotEmpty) return;

    final genresResponse = await getGenresCallback();
    state = genresResponse.genres;
  }
}
