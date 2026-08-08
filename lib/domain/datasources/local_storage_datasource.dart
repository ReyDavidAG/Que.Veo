import 'package:cinemapedia/config/database/database.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

abstract class LocalStorageDatasource {
  Future<void> toggleFavorite(Movie movie);
  Future<bool> isMovieFavorite(int movieId);
  Future<List<FavoriteMovy>> loadFavoriteMovies({
    int limit = 10,
    int offset = 0,
  });
}
