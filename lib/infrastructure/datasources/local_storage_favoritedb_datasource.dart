import 'package:cinemapedia/config/database/database.dart';
import 'package:cinemapedia/domain/datasources/local_storage_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:drift/drift.dart';

class LocalStorageFavoriteDBDatasource implements LocalStorageDatasource {
  final AppDatabase db;

  LocalStorageFavoriteDBDatasource({AppDatabase? database})
      : db = database ?? AppDatabase();
  @override
  Future<bool> isMovieFavorite(int movieId) async {
    // Construir el query
    final query = db.select(db.favoriteMovies)..where((table) => table.movieId.equals(movieId));

    // Ejecutar el query
    final favoriteMovie = await query.getSingleOrNull();

    // Retornar el resultado
    return favoriteMovie != null;
  }

  @override
  Future<List<FavoriteMovy>> loadFavoriteMovies({int limit = 10, int offset = 0}) async {
    // Query
    final query = db.select(db.favoriteMovies)..limit(limit, offset: offset);

    // Ejecutar el query
    final favoriteMovieRows = await query.get();

    return favoriteMovieRows;
  }

  @override
  Future<void> toggleFavorite(Movie movie) async {
    final isFavorite = await isMovieFavorite(movie.id);

    if (isFavorite) {
      final deleteQuery = db.delete(db.favoriteMovies)
        ..where((table) => table.movieId.equals(movie.id));

      await deleteQuery.go();
      return;
    }

    await db.into(db.favoriteMovies).insert(
          FavoriteMoviesCompanion.insert(
            movieId: movie.id,
            backdropPath: movie.backdropPath,
            originalTitle: movie.originalTitle,
            posterPath: movie.posterPath,
            title: movie.title,
            voteAverage: Value(movie.voteAverage),
          ),
        );
  }
}
