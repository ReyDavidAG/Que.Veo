import 'package:cinemapedia/config/storage/app_preferences.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentations/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchMoviesProvider = StateNotifierProvider<SearchedMoviesNotifier, List<Movie>>((ref) {
  final searchMoviesCallback = ref.read(movieRepositoryProvider);
  return SearchedMoviesNotifier(searchMovies: searchMoviesCallback.searchMovies, ref: ref);
});

typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {
  final SearchMoviesCallback searchMovies;
  final Ref ref;
  SearchedMoviesNotifier({required this.searchMovies, required this.ref}) : super([]);

  Future<List<Movie>> searchMoviesByQuery(String query) async {
    final List<Movie> movies = await searchMovies(query);

    ref.read(searchQueryProvider.notifier).update((state) => query);

    if (query.trim().isNotEmpty) {
      await _rememberQuery(query.trim());
    }

    state = movies;
    return movies;
  }

  Future<void> _rememberQuery(String query) async {
    final current = AppPreferences.instance.recentSearches;
    final updated = <String>[query, ...current.where((q) => q != query)];
    if (updated.length > 5) updated.removeRange(5, updated.length);
    await AppPreferences.instance.setRecentSearches(updated);
  }
}
